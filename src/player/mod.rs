use bevy::prelude::*;

use crate::game::{
    GROUND_Y, GameState, PLAYER_HEIGHT, PLAYER_WIDTH, PauseState, RUN_SPEED, WALK_SPEED,
};

pub struct PlayerPlugin;

impl Plugin for PlayerPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(OnEnter(GameState::InLobby), spawn_player)
            .add_systems(
                Update,
                (move_player, camera_follow).run_if(in_state(PauseState::Playing)),
            );
    }
}

#[derive(Component)]
pub struct Player;

fn spawn_player(mut commands: Commands, existing: Query<(), With<Player>>) {
    if !existing.is_empty() {
        return;
    }

    let player_y = GROUND_Y + PLAYER_HEIGHT / 2.0;

    commands.spawn((
        Player,
        Sprite {
            color: Color::srgb(0.12, 0.1, 0.08),
            custom_size: Some(Vec2::new(PLAYER_WIDTH, PLAYER_HEIGHT)),
            ..default()
        },
        Transform::from_xyz(0.0, player_y, 10.0),
    ));

    info!("Player spawned");
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
