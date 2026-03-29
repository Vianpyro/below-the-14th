use bevy::prelude::*;

use crate::game::{
    CORRIDOR_LENGTH, CorridorInfo, GROUND_Y, GameState, LOBBY_HALF_WIDTH, PauseState, RunState,
};
use crate::player::Player;

pub struct CorridorPlugin;

impl Plugin for CorridorPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(
            OnEnter(GameState::InLobby),
            (spawn_world, generate_corridor),
        )
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
    let ground_width = 20000.0;

    commands.spawn((
        WorldGround,
        Sprite {
            color: Color::srgb(0.08, 0.07, 0.06),
            custom_size: Some(Vec2::new(ground_width, ground_thickness)),
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
        Transform::from_xyz(0.0, GROUND_Y - ground_thickness / 2.0, 1.0),
    ));

    commands.spawn((
        WorldGround,
        Sprite {
            color: Color::srgb(0.06, 0.05, 0.04),
            custom_size: Some(Vec2::new(ground_width, 200.0)),
            ..default()
        },
        Transform::from_xyz(0.0, GROUND_Y + 500.0, 0.0),
    ));

    info!("World spawned");
}

fn generate_corridor(
    mut commands: Commands,
    mut corridor_info: ResMut<CorridorInfo>,
    run_state: Res<RunState>,
    old_markers: Query<Entity, With<CorridorEntity>>,
) {
    for entity in &old_markers {
        commands.entity(entity).despawn();
    }

    if run_state.passes_completed > 0 {
        corridor_info.direction *= -1.0;
    }

    let has_anomaly = rand::random_bool(0.5);
    corridor_info.has_anomaly = has_anomaly;

    let end_x = corridor_info.direction * (LOBBY_HALF_WIDTH + CORRIDOR_LENGTH);

    commands.spawn((
        CorridorEntity,
        Sprite {
            color: Color::srgb(0.6, 0.5, 0.3),
            custom_size: Some(Vec2::new(6.0, 400.0)),
            ..default()
        },
        Transform::from_xyz(end_x, GROUND_Y + 150.0, 2.0),
    ));

    for side in [-1.0_f32, 1.0] {
        commands.spawn((
            CorridorEntity,
            Sprite {
                color: Color::srgba(0.4, 0.35, 0.25, 0.3),
                custom_size: Some(Vec2::new(3.0, 300.0)),
                ..default()
            },
            Transform::from_xyz(side * LOBBY_HALF_WIDTH, GROUND_Y + 100.0, 2.0),
        ));
    }

    let direction_label = if corridor_info.direction > 0.0 {
        "right"
    } else {
        "left"
    };
    info!(
        "New corridor generated: direction={}, anomaly={}",
        direction_label, has_anomaly
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

    let exited = if corridor_info.direction > 0.0 {
        px > LOBBY_HALF_WIDTH
    } else {
        px < -LOBBY_HALF_WIDTH
    };

    if exited {
        info!("Player entered the corridor");
        next_state.set(GameState::InCorridor);
    }
}

fn check_corridor_thresholds(
    mut player_query: Query<&mut Transform, With<Player>>,
    corridor_info: Res<CorridorInfo>,
    mut run_state: ResMut<RunState>,
    mut next_state: ResMut<NextState<GameState>>,
) {
    let Ok(mut player_tf) = player_query.single_mut() else {
        return;
    };
    let px = player_tf.translation.x;

    let corridor_end = corridor_info.direction * (LOBBY_HALF_WIDTH + CORRIDOR_LENGTH);

    let reached_end = if corridor_info.direction > 0.0 {
        px >= corridor_end
    } else {
        px <= corridor_end
    };

    let returned_to_lobby = if corridor_info.direction > 0.0 {
        px < LOBBY_HALF_WIDTH
    } else {
        px > -LOBBY_HALF_WIDTH
    };

    if reached_end {
        evaluate_decision("keep_walking", corridor_info.has_anomaly, &mut run_state);

        player_tf.translation.x = 0.0;
        next_state.set(GameState::InLobby);
    } else if returned_to_lobby {
        evaluate_decision("turn_back", corridor_info.has_anomaly, &mut run_state);
        next_state.set(GameState::InLobby);
    }
}

fn evaluate_decision(action: &str, has_anomaly: bool, run_state: &mut RunState) {
    let correct = match (action, has_anomaly) {
        ("keep_walking", false) => true,
        ("keep_walking", true) => false,
        ("turn_back", true) => true,
        ("turn_back", false) => false,
        _ => unreachable!(),
    };

    if correct {
        let won = run_state.record_correct();
        info!(
            "CORRECT! Distance: {}m, streak: {}/{}",
            run_state.distance_remaining, run_state.consecutive_correct, run_state.streak_to_win
        );
        if won {
            info!("Player has reached the exit!");
        }
    } else {
        run_state.record_incorrect();
        info!(
            "INCORRECT. Distance reset to {}m. Anomaly was: {}",
            run_state.distance_remaining, has_anomaly
        );
    }
}
