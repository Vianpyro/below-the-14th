use bevy::prelude::*;

use crate::game::{GameState, RunState};

pub struct LobbyPlugin;

impl Plugin for LobbyPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(OnEnter(GameState::InLobby), spawn_ui)
            .add_systems(OnEnter(GameState::InLobby), update_distance_panel);
    }
}

#[derive(Component)]
struct DistancePanel;

#[derive(Component)]
struct StreakDisplay;

fn spawn_ui(mut commands: Commands, existing: Query<(), With<DistancePanel>>) {
    if !existing.is_empty() {
        return;
    }

    commands.spawn((
        DistancePanel,
        Text::new("EXIT - 80m"),
        TextFont {
            font_size: 36.0,
            ..default()
        },
        TextColor(Color::srgb(0.83, 0.63, 0.28)),
        TextLayout::new_with_justify(Justify::Center),
        Node {
            position_type: PositionType::Absolute,
            top: Val::Px(30.0),
            width: Val::Percent(100.0),
            ..default()
        },
    ));

    commands.spawn((
        StreakDisplay,
        Text::new("Streak: 0 / 8"),
        TextFont {
            font_size: 20.0,
            ..default()
        },
        TextColor(Color::srgb(0.54, 0.49, 0.42)),
        TextLayout::new_with_justify(Justify::Center),
        Node {
            position_type: PositionType::Absolute,
            top: Val::Px(75.0),
            width: Val::Percent(100.0),
            ..default()
        },
    ));
}

fn update_distance_panel(
    run_state: Res<RunState>,
    mut distance_query: Query<&mut Text, With<DistancePanel>>,
    mut streak_query: Query<&mut Text, (With<StreakDisplay>, Without<DistancePanel>)>,
) {
    if let Ok(mut text) = distance_query.single_mut() {
        *text = Text::new(format!("EXIT - {}m", run_state.distance_remaining));
    }
    if let Ok(mut text) = streak_query.single_mut() {
        *text = Text::new(format!(
            "Streak: {} / {}",
            run_state.consecutive_correct, run_state.streak_to_win
        ));
    }
}
