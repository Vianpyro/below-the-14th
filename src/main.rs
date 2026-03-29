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
        .add_systems(Startup, setup)
        .run();
}

/// Set up the 2D camera.
fn setup(mut commands: Commands) {
    commands.spawn(Camera2d);
}
