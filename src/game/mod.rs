use bevy::prelude::*;

pub struct GamePlugin;

impl Plugin for GamePlugin {
    fn build(&self, app: &mut App) {
        app.init_state::<GameState>()
            .add_computed_state::<InGame>()
            .add_sub_state::<PauseState>()
            .insert_resource(RunState::default())
            .insert_resource(CorridorInfo::default());
    }
}

pub const LOBBY_HALF_WIDTH: f32 = 600.0;

pub const CORRIDOR_LENGTH: f32 = 4000.0;

pub const GROUND_Y: f32 = -250.0;

pub const PLAYER_HEIGHT: f32 = 120.0;

pub const PLAYER_WIDTH: f32 = 40.0;

pub const WALK_SPEED: f32 = 300.0;

pub const RUN_SPEED: f32 = 600.0;

#[derive(States, Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
pub enum GameState {
    #[default]
    MainMenu,
    InLobby,
    InCorridor,
    GameEnd,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct InGame;

impl ComputedStates for InGame {
    type SourceStates = Option<GameState>;

    fn compute(sources: Option<GameState>) -> Option<Self> {
        match sources {
            Some(GameState::InLobby | GameState::InCorridor) => Some(InGame),
            _ => None,
        }
    }
}

#[derive(SubStates, Debug, Clone, Copy, PartialEq, Eq, Hash, Default)]
#[source(InGame = InGame)]
pub enum PauseState {
    #[default]
    Playing,
    Paused,
}

#[derive(Resource, Debug)]
pub struct RunState {
    pub distance_remaining: f32,
    pub distance_max: f32,
    pub distance_per_correct: f32,
    pub consecutive_correct: u32,
    pub streak_to_win: u32,
    pub passes_completed: u32,
    pub anomaly_probability: f32,
}

impl Default for RunState {
    fn default() -> Self {
        Self {
            distance_remaining: 80.0,
            distance_max: 80.0,
            distance_per_correct: 10.0,
            consecutive_correct: 0,
            streak_to_win: 8,
            passes_completed: 0,
            anomaly_probability: 0.5,
        }
    }
}

impl RunState {
    pub fn record_correct(&mut self) -> bool {
        self.consecutive_correct += 1;
        self.distance_remaining -= self.distance_per_correct;
        self.passes_completed += 1;

        if self.distance_remaining <= 0.0 {
            self.distance_remaining = 0.0;
        }

        self.consecutive_correct >= self.streak_to_win
    }

    pub fn record_incorrect(&mut self) {
        self.consecutive_correct = 0;
        self.distance_remaining = self.distance_max;
        self.passes_completed += 1;
    }
}

#[derive(Resource, Debug)]
pub struct CorridorInfo {
    pub has_anomaly: bool,

    pub direction: f32,
}

impl Default for CorridorInfo {
    fn default() -> Self {
        Self {
            has_anomaly: false,
            direction: 1.0,
        }
    }
}
