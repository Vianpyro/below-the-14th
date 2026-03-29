mod accessibility;
mod anomaly;
mod audio;
mod corridor;
mod game;
mod input;
mod lighting;
mod lobby;
mod menu;
mod persistence;
mod player;

use bevy::prelude::*;

fn main() {
    App::new()
        .add_plugins(DefaultPlugins.set(WindowPlugin {
            primary_window: Some(Window {
                title: "Below the 14th".into(),
                mode: bevy::window::WindowMode::BorderlessFullscreen(MonitorSelection::Current),
                ..default()
            }),
            ..default()
        }))
        .insert_resource(ClearColor(Color::srgb(0.1, 0.09, 0.08)))
        .add_plugins((game::GamePlugin, input::InputPlugin))
        .add_systems(Startup, setup)
        .run();
}

fn setup(mut commands: Commands) {
    commands.spawn(Camera2d);
}
