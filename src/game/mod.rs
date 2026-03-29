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
pub const CORRIDOR_LEFT_EDGE: f32 = -(CORRIDOR_LENGTH / 2.0);
pub const CORRIDOR_RIGHT_EDGE: f32 = CORRIDOR_LENGTH / 2.0;
pub const LEFT_LOBBY_X: f32 = CORRIDOR_LEFT_EDGE - LOBBY_HALF_WIDTH;
pub const RIGHT_LOBBY_X: f32 = CORRIDOR_RIGHT_EDGE + LOBBY_HALF_WIDTH;

pub const WORLD_LEFT_EDGE: f32 = LEFT_LOBBY_X - LOBBY_HALF_WIDTH;

pub const WORLD_RIGHT_EDGE: f32 = RIGHT_LOBBY_X + LOBBY_HALF_WIDTH;

pub const WORLD_WIDTH: f32 = WORLD_RIGHT_EDGE - WORLD_LEFT_EDGE;

pub const GROUND_Y: f32 = -250.0;
pub const PLAYER_HEIGHT: f32 = 120.0;
pub const PLAYER_WIDTH: f32 = 40.0;
pub const WALK_SPEED: f32 = 300.0;
pub const RUN_SPEED: f32 = 600.0;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LobbyId {
    Left,
    Right,
}

impl LobbyId {
    pub fn opposite(self) -> Self {
        match self {
            LobbyId::Left => LobbyId::Right,
            LobbyId::Right => LobbyId::Left,
        }
    }

    pub fn center_x(self) -> f32 {
        match self {
            LobbyId::Left => LEFT_LOBBY_X,
            LobbyId::Right => RIGHT_LOBBY_X,
        }
    }

    pub fn near_corridor_edge(self) -> f32 {
        match self {
            LobbyId::Left => CORRIDOR_LEFT_EDGE,
            LobbyId::Right => CORRIDOR_RIGHT_EDGE,
        }
    }

    pub fn far_corridor_edge(self) -> f32 {
        self.opposite().near_corridor_edge()
    }

    pub fn forward_dir(self) -> f32 {
        match self {
            LobbyId::Left => 1.0,
            LobbyId::Right => -1.0,
        }
    }
}

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
        self.passes_completed += 1;
        self.distance_remaining = (self.distance_remaining - self.distance_per_correct).max(0.0);
        self.consecutive_correct >= self.streak_to_win
    }

    pub fn record_incorrect(&mut self) {
        self.consecutive_correct = 0;
        self.passes_completed += 1;
        self.distance_remaining = self.distance_max;
    }
}

#[derive(Resource, Debug)]
pub struct CorridorInfo {
    pub has_anomaly: bool,

    pub current_lobby: LobbyId,

    pub origin_lobby: LobbyId,
}

impl Default for CorridorInfo {
    fn default() -> Self {
        Self {
            has_anomaly: false,
            current_lobby: LobbyId::Left,
            origin_lobby: LobbyId::Left,
        }
    }
}
