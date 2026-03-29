use bevy::prelude::*;

use crate::game::{
    GROUND_Y, GameState, LEFT_LOBBY_X, LOBBY_HALF_WIDTH, PLAYER_HEIGHT, PLAYER_WIDTH, PauseState,
    RUN_SPEED, WALK_SPEED, WORLD_LEFT_EDGE, WORLD_RIGHT_EDGE, WORLD_WIDTH,
};

pub struct PlayerPlugin;

impl Plugin for PlayerPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(OnEnter(GameState::InLobby), spawn_player)
            .add_systems(
                Update,
                (move_player, wrap_player, camera_follow)
                    .chain()
                    .run_if(in_state(PauseState::Playing)),
            );
    }
}

#[derive(Component)]
pub struct Player;

fn spawn_player(mut commands: Commands, existing: Query<(), With<Player>>) {
    if !existing.is_empty() {
        return;
    }

    commands.spawn((
        Player,
        Sprite {
            color: Color::srgb(0.12, 0.1, 0.08),
            custom_size: Some(Vec2::new(PLAYER_WIDTH, PLAYER_HEIGHT)),
            ..default()
        },
        Transform::from_xyz(LEFT_LOBBY_X, GROUND_Y + PLAYER_HEIGHT / 2.0, 10.0),
    ));

    info!("Player spawned at left lobby (x={LEFT_LOBBY_X})");
}

fn move_player(
    keyboard: Res<ButtonInput<KeyCode>>,
    time: Res<Time>,
    mut query: Query<&mut Transform, With<Player>>,
) {
    let Ok(mut transform) = query.single_mut() else {
        return;
    };

    let mut direction = 0.0;
    if keyboard.pressed(KeyCode::KeyD) || keyboard.pressed(KeyCode::ArrowRight) {
        direction += 1.0;
    }
    if keyboard.pressed(KeyCode::KeyA) || keyboard.pressed(KeyCode::ArrowLeft) {
        direction -= 1.0;
    }

    if direction != 0.0 {
        let speed = if keyboard.pressed(KeyCode::ShiftLeft) || keyboard.pressed(KeyCode::ShiftRight)
        {
            RUN_SPEED
        } else {
            WALK_SPEED
        };
        transform.translation.x += direction * speed * time.delta_secs();
    }
}

fn wrap_player(mut query: Query<&mut Transform, With<Player>>) {
    let Ok(mut tf) = query.single_mut() else {
        return;
    };

    if tf.translation.x > WORLD_RIGHT_EDGE {
        tf.translation.x -= WORLD_WIDTH - LOBBY_HALF_WIDTH * 2.0;
        info!("Wrapped: right → left outer edge");
    } else if tf.translation.x < WORLD_LEFT_EDGE {
        tf.translation.x += WORLD_WIDTH - LOBBY_HALF_WIDTH * 2.0;
        info!("Wrapped: left → right outer edge");
    }
}

fn camera_follow(
    player_query: Query<&Transform, With<Player>>,
    mut camera_query: Query<&mut Transform, (With<Camera2d>, Without<Player>)>,
) {
    let Ok(player_tf) = player_query.single() else {
        return;
    };
    let Ok(mut camera_tf) = camera_query.single_mut() else {
        return;
    };
    camera_tf.translation.x = player_tf.translation.x;
}
