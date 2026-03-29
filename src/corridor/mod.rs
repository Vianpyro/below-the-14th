use bevy::prelude::*;

use crate::game::{
    CORRIDOR_LEFT_EDGE, CORRIDOR_RIGHT_EDGE, CorridorInfo, GROUND_Y, GameState, LEFT_LOBBY_X,
    LOBBY_HALF_WIDTH, LobbyId, PauseState, RIGHT_LOBBY_X, RunState,
};
use crate::player::Player;

pub struct CorridorPlugin;

impl Plugin for CorridorPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(OnEnter(GameState::InLobby), spawn_world)
            .add_systems(OnEnter(GameState::InCorridor), generate_corridor)
            .add_systems(
                Update,
                (
                    check_lobby_exit.run_if(in_state(GameState::InLobby)),
                    check_corridor_thresholds.run_if(in_state(GameState::InCorridor)),
                )
                    .run_if(in_state(PauseState::Playing)),
            );
    }
}

#[derive(Component)]
struct WorldGround;

#[derive(Component)]
struct CorridorEntity;

fn spawn_world(mut commands: Commands, existing: Query<(), With<WorldGround>>) {
    if !existing.is_empty() {
        return;
    }

    let ground_thickness = 80.0;
    let world_width = 10_000.0;

    commands.spawn((
        WorldGround,
        Sprite {
            color: Color::srgb(0.08, 0.07, 0.06),
            custom_size: Some(Vec2::new(world_width, ground_thickness)),
            ..default()
        },
        Transform::from_xyz(0.0, GROUND_Y - ground_thickness / 2.0, 0.0),
    ));

    commands.spawn((
        WorldGround,
        Sprite {
            color: Color::srgb(0.14, 0.12, 0.1),
            custom_size: Some(Vec2::new(LOBBY_HALF_WIDTH * 2.0, ground_thickness)),
            ..default()
        },
        Transform::from_xyz(LEFT_LOBBY_X, GROUND_Y - ground_thickness / 2.0, 1.0),
    ));

    commands.spawn((
        WorldGround,
        Sprite {
            color: Color::srgb(0.14, 0.12, 0.1),
            custom_size: Some(Vec2::new(LOBBY_HALF_WIDTH * 2.0, ground_thickness)),
            ..default()
        },
        Transform::from_xyz(RIGHT_LOBBY_X, GROUND_Y - ground_thickness / 2.0, 1.0),
    ));

    commands.spawn((
        WorldGround,
        Sprite {
            color: Color::srgb(0.06, 0.05, 0.04),
            custom_size: Some(Vec2::new(world_width, 200.0)),
            ..default()
        },
        Transform::from_xyz(0.0, GROUND_Y + 500.0, 0.0),
    ));

    info!("World spawned (left lobby: {LEFT_LOBBY_X}, right lobby: {RIGHT_LOBBY_X})");
}

fn generate_corridor(
    mut commands: Commands,
    mut corridor_info: ResMut<CorridorInfo>,
    old_entities: Query<Entity, With<CorridorEntity>>,
) {
    for entity in &old_entities {
        commands.entity(entity).despawn();
    }

    corridor_info.origin_lobby = corridor_info.current_lobby;

    let has_anomaly = rand::random_bool(0.5);
    corridor_info.has_anomaly = has_anomaly;

    let far_x = corridor_info.origin_lobby.far_corridor_edge();

    commands.spawn((
        CorridorEntity,
        Sprite {
            color: Color::srgb(0.6, 0.5, 0.3),
            custom_size: Some(Vec2::new(6.0, 400.0)),
            ..default()
        },
        Transform::from_xyz(far_x, GROUND_Y + 150.0, 2.0),
    ));

    commands.spawn((
        CorridorEntity,
        Sprite {
            color: Color::srgba(0.4, 0.35, 0.25, 0.5),
            custom_size: Some(Vec2::new(4.0, 300.0)),
            ..default()
        },
        Transform::from_xyz(0.0, GROUND_Y + 100.0, 1.5),
    ));

    info!(
        "Corridor generated -- origin: {:?}, far end: x={far_x:.0}, anomaly: {has_anomaly}",
        corridor_info.origin_lobby
    );
}

fn check_lobby_exit(
    player_query: Query<&Transform, With<Player>>,
    corridor_info: Res<CorridorInfo>,
    mut next_state: ResMut<NextState<GameState>>,
) {
    let Ok(player_tf) = player_query.single() else {
        return;
    };
    let px = player_tf.translation.x;

    let exited = match corridor_info.current_lobby {
        LobbyId::Left => px > CORRIDOR_LEFT_EDGE,
        LobbyId::Right => px < CORRIDOR_RIGHT_EDGE,
    };

    if exited {
        info!(
            "Entered corridor from {:?} lobby",
            corridor_info.current_lobby
        );
        next_state.set(GameState::InCorridor);
    }
}

fn check_corridor_thresholds(
    player_query: Query<&Transform, With<Player>>,
    mut corridor_info: ResMut<CorridorInfo>,
    mut run_state: ResMut<RunState>,
    mut next_state: ResMut<NextState<GameState>>,
) {
    let Ok(player_tf) = player_query.single() else {
        return;
    };
    let px = player_tf.translation.x;
    let origin = corridor_info.origin_lobby;

    let reached_far = match origin {
        LobbyId::Left => px >= CORRIDOR_RIGHT_EDGE,
        LobbyId::Right => px <= CORRIDOR_LEFT_EDGE,
    };

    const RETURN_BUFFER: f32 = 20.0;
    let returned_to_origin = match origin {
        LobbyId::Left => px <= CORRIDOR_LEFT_EDGE - RETURN_BUFFER,
        LobbyId::Right => px >= CORRIDOR_RIGHT_EDGE + RETURN_BUFFER,
    };

    if reached_far {
        let won = evaluate_decision("keep_walking", corridor_info.has_anomaly, &mut run_state);
        corridor_info.current_lobby = origin.opposite();
        info!(
            "Reached far end -> now in {:?} lobby",
            corridor_info.current_lobby
        );
        if won {
            info!("Player reached the exit -- game complete!");
        }
        next_state.set(GameState::InLobby);
    } else if returned_to_origin {
        evaluate_decision("turn_back", corridor_info.has_anomaly, &mut run_state);
        corridor_info.current_lobby = origin;
        info!(
            "Turned back -> still in {:?} lobby",
            corridor_info.current_lobby
        );
        next_state.set(GameState::InLobby);
    }
}

fn evaluate_decision(action: &str, has_anomaly: bool, run_state: &mut RunState) -> bool {
    let correct = matches!(
        (action, has_anomaly),
        ("keep_walking", false) | ("turn_back", true)
    );

    if correct {
        let won = run_state.record_correct();
        info!(
            "Correct -- {}m remaining, streak {}/{}",
            run_state.distance_remaining, run_state.consecutive_correct, run_state.streak_to_win
        );
        won
    } else {
        run_state.record_incorrect();
        info!(
            "Incorrect -- reset to {}m (anomaly was: {has_anomaly})",
            run_state.distance_remaining
        );
        false
    }
}
