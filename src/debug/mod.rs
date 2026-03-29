use bevy::prelude::*;

use crate::game::{
    CORRIDOR_LEFT_EDGE, CORRIDOR_RIGHT_EDGE, CorridorInfo, GROUND_Y, GameState, LEFT_LOBBY_X,
    PauseState, RIGHT_LOBBY_X, RunState, WORLD_LEFT_EDGE, WORLD_RIGHT_EDGE,
};
use crate::player::Player;

pub struct DebugPlugin;

impl Plugin for DebugPlugin {
    fn build(&self, app: &mut App) {
        app.insert_resource(DebugConfig { visible: false })
            .add_systems(Update, manage_debug_overlay);
    }
}

#[derive(Resource)]
struct DebugConfig {
    visible: bool,
}

#[derive(Component)]
struct DebugOverlay;

#[derive(Component)]
struct DebugWorldMarker;

struct MarkerDef {
    x: f32,

    color: Color,
}

fn marker_defs() -> &'static [MarkerDef] {
    &MARKERS
}

static MARKERS: [MarkerDef; 7] = [
    MarkerDef {
        x: WORLD_LEFT_EDGE,
        color: Color::srgb(0.85, 0.15, 0.15),
    },
    MarkerDef {
        x: WORLD_RIGHT_EDGE,
        color: Color::srgb(0.85, 0.15, 0.15),
    },
    MarkerDef {
        x: LEFT_LOBBY_X,
        color: Color::srgb(0.25, 0.45, 0.90),
    },
    MarkerDef {
        x: RIGHT_LOBBY_X,
        color: Color::srgb(0.25, 0.45, 0.90),
    },
    MarkerDef {
        x: CORRIDOR_LEFT_EDGE,
        color: Color::srgb(0.90, 0.60, 0.10),
    },
    MarkerDef {
        x: CORRIDOR_RIGHT_EDGE,
        color: Color::srgb(0.90, 0.60, 0.10),
    },
    MarkerDef {
        x: 0.0,
        color: Color::srgba(0.7, 0.7, 0.7, 0.4),
    },
];

fn manage_debug_overlay(
    mut commands: Commands,
    keyboard: Res<ButtonInput<KeyCode>>,
    mut config: ResMut<DebugConfig>,
    player_query: Query<&Transform, With<Player>>,
    game_state: Res<State<GameState>>,
    pause_state: Option<Res<State<PauseState>>>,
    run_state: Option<Res<RunState>>,
    corridor_info: Option<Res<CorridorInfo>>,

    mut overlay_query: Query<(Entity, &mut Text), With<DebugOverlay>>,
    marker_query: Query<Entity, With<DebugWorldMarker>>,
) {
    if keyboard.just_pressed(KeyCode::F3) {
        config.visible = !config.visible;

        if !config.visible {
            for (entity, _) in &overlay_query {
                commands.entity(entity).despawn();
            }

            for entity in &marker_query {
                commands.entity(entity).despawn();
            }
            return;
        }

        let line_height = 600.0;
        let line_y = GROUND_Y + line_height / 2.0;

        for marker in marker_defs() {
            commands.spawn((
                DebugWorldMarker,
                Sprite {
                    color: marker.color,
                    custom_size: Some(Vec2::new(2.0, line_height)),
                    ..default()
                },
                Transform::from_xyz(marker.x, line_y, 50.0),
            ));
        }
    }

    if !config.visible {
        return;
    }

    let player_x = player_query
        .single()
        .map(|t| format!("{:+.0}", t.translation.x))
        .unwrap_or_else(|_| "--".to_string());

    let pause_str = pause_state
        .as_ref()
        .map(|p| format!("{:?}", p.get()))
        .unwrap_or_else(|| "N/A".to_string());

    let (lobby_str, origin_str, anomaly_str) = corridor_info
        .as_ref()
        .map(|ci| {
            (
                format!("{:?}", ci.current_lobby),
                format!("{:?}", ci.origin_lobby),
                if ci.has_anomaly {
                    "YES".to_string()
                } else {
                    "no".to_string()
                },
            )
        })
        .unwrap_or_else(|| ("--".into(), "--".into(), "--".into()));

    let (dist_str, streak_str, passes_str) = run_state
        .as_ref()
        .map(|rs| {
            (
                format!("{}m", rs.distance_remaining),
                format!("{} / {}", rs.consecutive_correct, rs.streak_to_win),
                format!("{}", rs.passes_completed),
            )
        })
        .unwrap_or_else(|| ("--".into(), "--".into(), "--".into()));

    let content = format!(
        "[ F3 ] DEBUG\n\
         \n\
         Player X     {player_x}\n\
         State        {game_state:?}\n\
         Pause        {pause_str}\n\
         \n\
         Lobby        {lobby_str}\n\
         Origin       {origin_str}\n\
         Anomaly      {anomaly_str}\n\
         \n\
         Distance     {dist_str}\n\
         Streak       {streak_str}\n\
         Passes       {passes_str}\n\
         \n\
         = lines ==========\n\
         red    wrap  +-3200\n\
         blue   lobby +-2600\n\
         amber  corr  +-2000\n\
         grey   centre   0",
        game_state = game_state.get(),
    );

    if let Ok((_, mut text)) = overlay_query.single_mut() {
        *text = Text::new(content);
    } else {
        commands.spawn((
            DebugOverlay,
            Text::new(content),
            TextFont {
                font_size: 14.0,
                ..default()
            },
            TextColor(Color::srgba(0.4, 1.0, 0.6, 0.9)),
            Node {
                position_type: PositionType::Absolute,
                top: Val::Px(10.0),
                right: Val::Px(10.0),
                ..default()
            },
        ));
    }
}
