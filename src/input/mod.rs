use bevy::prelude::*;

use crate::game::{GameState, PauseState};

pub struct InputPlugin;

impl Plugin for InputPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(Update, handle_escape);
    }
}

fn handle_escape(
    keyboard: Res<ButtonInput<KeyCode>>,
    game_state: Res<State<GameState>>,
    pause_state: Option<Res<State<PauseState>>>,
    mut next_pause: Option<ResMut<NextState<PauseState>>>,
    mut exit_events: MessageWriter<AppExit>,
) {
    if !keyboard.just_pressed(KeyCode::Escape) {
        return;
    }

    match game_state.get() {
        GameState::InLobby | GameState::InCorridor => {
            if let (Some(pause), Some(next)) = (&pause_state, &mut next_pause) {
                let new_state = match pause.get() {
                    PauseState::Playing => {
                        info!("Game paused");
                        PauseState::Paused
                    }
                    PauseState::Paused => {
                        info!("Game resumed");
                        PauseState::Playing
                    }
                };
                next.set(new_state);
            }
        }
        _ => {
            info!("Quitting game");
            exit_events.write(AppExit::Success);
        }
    }
}
