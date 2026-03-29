#import "/wiki/template.typ": *

#show: wiki-page.with(
  title: "Technical Design",
  subtitle: "Architecture, Systems, and Implementation",
  version: "1.0",
)

= Engine & Platform

- *Engine:* Bevy (Rust)
- *Platform:* PC first (Steam), console potential post-release
- *Display:* Fullscreen windowed, adaptive resolution
- *Dev reference resolution:* 2560×1440
- *Language:* English first, French localization later

The developer is a Bevy beginner with Rust experience (completed a Breakout clone in Bevy). Code should be well-commented, idiomatic Bevy ECS, and incrementally testable.


= Project Structure

Single crate, modular organization:

```
below_the_14th/
├── src/
│   ├── main.rs
│   ├── game/           # Core game state, progression, streak logic
│   ├── corridor/       # Corridor generation, canonical state, zones
│   ├── anomaly/        # Anomaly pool, selection, placement, tagging
│   ├── lobby/          # Lobby generation, UI panels, collection menu
│   ├── player/         # Player movement, input handling
│   ├── lighting/       # Torch shader, illumination system
│   ├── audio/          # Soundscape generation, spatial audio, VFX
│   ├── input/          # Keyboard/mouse/gamepad abstraction
│   ├── accessibility/  # Mode switching, pool filtering, blind nav
│   ├── persistence/    # Save/load anomaly collection, settings
│   └── menu/           # Main menu, pause overlay, options
├── assets/
│   ├── shaders/        # WGSL shaders (torch, lighting)
│   ├── sounds/         # Open-source VFX audio
│   ├── textures/       # Open-source object textures (if any)
│   └── fonts/          # UI fonts
├── Cargo.toml
└── CLAUDE.md
```


= State Machine

== Bevy States

```
MainMenu → InLobby → InCorridor → InLobby → ... → GameEnd
                ↕
          PauseOverlay (sub-state)
          CollectionMenu (sub-state)
```

- *Bevy States* for high-level transitions (menu, lobby, corridor, end).
- *Sub-states* for pause and collection menu (overlay on top of current state).
- State transitions trigger cleanup/setup systems for spawning and despawning entities.


= Input System

== Abstraction Layer

All game logic reads from an abstract input system, never directly from keyboard/mouse/gamepad. This makes control remapping and accessibility clean.

#callout(title: "Architecture Rule")[
  No system outside the `input` module should reference `KeyCode`, `MouseButton`, or `GamepadButton` directly. Everything goes through the abstraction.
]

== Input Actions

#table(
  columns: (1.2fr, 1.5fr, 1.5fr),
  [Action], [Keyboard + Mouse], [Gamepad],
  [Move], [WASD / Arrow keys], [Left stick],
  [Run], [Shift], [A/X button or trigger],
  [Aim torch], [Mouse position (2D)], [Right stick (2D)],
  [Pause], [Escape], [Start],
)

== Movement

- Two speeds: walk and run. Running is always available.
- No jump. Movement is horizontal only.
- The game rewards slowness but never punishes speed mechanically.


= Core Game Loop Implementation

== Game State Resource

A Bevy resource tracks the run state:

- `distance_remaining`: starts at `distance_max`, reduced by `distance_per_correct` on success, reset to `distance_max` on failure.
- `consecutive_correct`: streak counter. When it reaches `streak_to_win`, trigger ending.
- `current_corridor_has_anomaly`: `Option<AnomalyId>` — set at corridor generation.
- `corridor_decision`: enum tracking whether the player kept walking or turned back.
- `passes_completed`: total passes this run (used for difficulty tier unlocking).

== Corridor Generation

When the player commits to a new corridor:

+ Destroy the previous preserved corridor (if any).
+ Generate corridor geometry with canonical state.
+ Roll for anomaly: 50% chance.
+ If anomaly: run the selection algorithm (filter by tier + sensory channel, prioritize undiscovered, weighted random fallback).
+ Place the anomaly in the corridor.

== Decision Detection

The decision is physical, not UI-based:

- *Keep walking:* the player reaches the far-end threshold of the corridor. The game evaluates: was there an anomaly? If yes → incorrect. If no → correct.
- *Turn back:* the player returns to the lobby threshold from within the corridor. The game evaluates: was there an anomaly? If yes → correct. If no → incorrect.

No midpoint marker. No explicit "report anomaly" button.


= Anomaly Data Architecture

== Anomaly as Data

Each anomaly is a data definition, not hard-coded behavior:

```rust
struct AnomalyDef {
    id: AnomalyId,
    name: String,
    description: String,
    category: AnomalyCategory,
    sensory_channel: SensoryChannel,  // Visual, Audio, Both
    difficulty_tier: u8,              // 1, 2, or 3
    // Placement and rendering data...
}
```

== Sensory Channel Filtering

Filtering happens at the *selection* level, not the rendering level:

#table(
  columns: (1fr, 2fr),
  [Mode], [Pool Filter],
  [Standard], [All anomalies],
  [Deaf], [`Visual` + `Both` only],
  [Blind], [`Audio` + `Both` only],
)

In deaf mode, audio anomalies are simply never selected. In blind mode, visual anomalies are never selected.


= Lighting System

== Torch Implementation

The torch is implemented via *WGSL shaders*:

- Follows mouse/right stick in full 2D (up, down, left, right).
- Illuminates a warm, imperfect cone of light.
- Soft falloff at edges — not a hard circle.
- Battery is unlimited.
- Light projects *forward/outward from the player*, keeping the player character in permanent silhouette (backlit against their own light).

== Shader Parameters

#table(
  columns: (1.2fr, 1fr, 2fr),
  [Parameter], [Default], [Notes],
  [`torch_radius`], [TBD], [Base radius of illumination cone],
  [`torch_falloff`], [TBD], [Softness of edge falloff],
  [`torch_color`], [Warm ochre/amber], [Color temperature of light],
  [`ambient_color`], [Cold grey-blue], [Color of unlit areas],
  [`ambient_intensity`], [Very low], [How much is visible without torch],
)

== Parallax Layers

Three depth layers, each affected differently by the torch:

+ *Background:* torch barely reaches — limestone, cracks, moisture.
+ *Midground:* primary illumination — ossuaire walls, objects, anomaly zone.
+ *Foreground:* always partially lit — stone frame edges, ceiling.


= Audio System

== Procedural Soundscape

Inspired by myNoise — layered, continuous, generated from parameters:

- *Base layers:* water drips, fluorescent hum, air current.
- *Event sounds:* structure creaks (periodic), air breath (once per traversal).
- *Player sounds:* footsteps with wet stone echo.

All layers have spatial position (left/right based on source location in corridor).

== Soundscape Arc

Parameters shift subtly as the player progresses:

#table(
  columns: (1fr, 2.5fr),
  [Phase], [Character],
  [Early passes], [Neutral, realistic catacomb ambiance],
  [Mid passes],
  [Same sounds, mix shifts — frequencies slightly wrong, silences louder],

  [Late passes], [Soundscape unreliable — audio anomalies maximally effective],
  [Final corridor], [Near silence — dripping stopped, hum gone, excessive echo],
)

== Open-Source VFX

One-shot sounds (footsteps, drips, creaks, impacts) sourced from open-source libraries. No composed music — everything the player hears should be explainable by the physical space.


= Spatial Audio (Blind Mode)

Required for blind mode, beneficial for all modes:

- Sounds have spatial position (left/right based on source location).
- *Wall proximity:* sound cue intensifies near walls.
- *Floor texture:* footstep sound changes based on surface.
- *Lobby beacon:* continuous low hum, always spatially locatable.
- Footstep echo behavior reflects corridor geometry.


= Persistence

== Local Storage

- *Anomaly collection:* which anomalies discovered. Survives between sessions.
- *Settings:* accessibility mode, audio/visual preferences, control bindings.

== Not Persisted

- Run progress: distance, streak, corridor state. Fresh every session.

== File Format

TBD — likely a simple JSON or RON file in the platform's standard app data directory.


= Development Priorities

#callout(title: "Philosophy")[
  Solo project, no deadlines. Quality over speed. Each feature should be runnable and verifiable before moving to the next.
]

+ *Core loop:* Walk through corridor, turn back, reach lobby, distance panel updates. No anomalies — just traversal.
+ *Canonical corridor:* Correct rendering with all canonical objects. Procedural textures. Torch lighting.
+ *Anomaly system:* One anomaly per category, correctly placed and detected. Selection and tagging working.
+ *Lobby and progression:* Distance panel, streak logic, reset on error, anomaly counter.
+ *Audio:* Canonical soundscape, spatial audio foundation.
+ *Accessibility modes:* Deaf mode (pool filtering). Blind mode (spatial navigation).
+ *Content expansion:* Fill anomaly catalogue. Difficulty tiering. Polish.
+ *Ending sequence:* The double. The final decision. Fade to black.
+ *Persistence:* Save/load anomaly collection and settings.
+ *Menus:* Main menu in first lobby. Options. Pause overlay.
+ *Polish and playtesting:* Tune all configurable parameters.
