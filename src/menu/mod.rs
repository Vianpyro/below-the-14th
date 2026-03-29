use bevy::prelude::*;

use crate::game::GameState;

pub struct MenuPlugin;

impl Plugin for MenuPlugin {
    fn build(&self, app: &mut App) {
        app.add_systems(OnEnter(GameState::MainMenu), show_menu)
            .add_systems(
                Update,
                handle_menu_input.run_if(in_state(GameState::MainMenu)),
            )
            .add_systems(OnExit(GameState::MainMenu), cleanup_menu);
    }
}

#[derive(Component)]
struct MenuElement;

fn show_menu(mut commands: Commands) {
    commands.spawn((
        MenuElement,
        Text::new("BELOW THE 14TH\n\nPress Enter to begin"),
        TextFont {
            font_size: 32.0,
            ..default()
        },
        TextColor(Color::srgb(0.83, 0.63, 0.28)),
        TextLayout::new_with_justify(Justify::Center),
        Node {
            width: Val::Percent(100.0),
            height: Val::Percent(100.0),
            justify_content: JustifyContent::Center,
            align_items: AlignItems::Center,
            ..default()
        },
    ));
}

fn handle_menu_input(
    keyboard: Res<ButtonInput<KeyCode>>,
    mut next_state: ResMut<NextState<GameState>>,
) {
    if keyboard.just_pressed(KeyCode::Enter) {
        info!("Starting game");
        next_state.set(GameState::InLobby);
    }
}

fn cleanup_menu(mut commands: Commands, query: Query<Entity, With<MenuElement>>) {
    for entity in &query {
        commands.entity(entity).despawn();
    }
}
