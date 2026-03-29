# CLAUDE.md — Below the 14th

> This is the single reference document for building _Below the 14th_. Every Claude session working on this project should read this file first. It is the source of truth — the prototype GDD is superseded by this document wherever they conflict.

---

## Project Identity

- **Title (working):** Below the 14th
- **Genre:** Psychological puzzle / anomaly detection (side-scrolling 2D)
- **Engine:** Bevy (Rust)
- **Platform:** PC first (Steam), console potential post-release
- **Target playtime:** 30–45 minutes (average first playthrough)
- **Display:** Fullscreen windowed, adaptive resolution (dev reference: 2560×1440)
- **Language:** English first, French localization later
- **Solo project** — Claude is the primary collaborator for code, design, art pipeline, and audio

---

## The Game in One Paragraph

The player is an urban explorer trapped in a looping catacomb corridor beneath Paris. Each pass through the corridor may or may not contain a single anomaly — a deviation from the canonical state of the environment. The player must decide: keep walking (nothing is wrong) or turn back (something is wrong). Correct consecutive decisions bring them closer to the exit. Any mistake resets all progress. The game ends when the player reaches the exit. The tension comes from attention, memory, and doubt — never from combat, timers, or jump scares.

---

## Core Traversal Model

This is the most important system in the game. Read carefully.

### The World Structure

The world is a linear sequence generated on the fly: **lobby → corridor → lobby → corridor → lobby...** There is no fixed map. Lobbies and corridors do not have persistent positions in space — they are created ahead of the player and destroyed behind them as needed.

### The First Lobby (Session Start)

The very first lobby of a run is unique: it has **two corridors**, one on each side, generated independently (each with its own 50/50 anomaly chance). The player chooses a direction — this is the only moment in the game where a directional choice exists. After this first choice, all subsequent lobbies follow the standard model below.

### How a Pass Works

1. The player is in a **lobby**. The lobby displays the **distance panel** (distance remaining to exit + anomalies found/total discovered). The player can stay as long as they want.
2. The player walks into the **corridor**. In a standard lobby, one direction leads to the preserved previous corridor (for verification) and the other leads to the next generated corridor. The corridor has a fixed, canonical length — always the same.
3. The corridor either contains **one anomaly** or **no anomaly** (50% chance each, determined randomly at generation).
4. The player makes a decision:

**Option A — Keep walking (reach the far end):**
- If the corridor was clean → **CORRECT**. Distance reduced. A new lobby is generated at the far end. The old corridor remains accessible behind the player.
- If the corridor had an anomaly the player missed → **INCORRECT**. Progress resets. The new lobby shows the reset. The old corridor (with the missed anomaly) remains accessible behind the player so they can go back and find what they missed.

**Option B — Turn back (return to the lobby they came from):**
- If the corridor had an anomaly → **CORRECT**. Distance reduced. The corridor remains intact behind the player (they can re-enter to confirm what they saw). A new corridor is generated in the opposite direction when the player is ready.
- If the corridor was clean → **INCORRECT**. Progress resets. The corridor remains accessible so the player sees there was nothing wrong.

### Critical Rule: Corridor Preservation

The last traversed corridor is **always preserved** until the player commits to the next one. This serves the learning loop — the player can always go back and verify their decision. The old corridor is only destroyed when the player crosses the threshold into a new corridor.

### Progression

- Each correct decision reduces the distance to the exit by a fixed amount.
- Each incorrect decision **resets distance to maximum** (back to square one).
- The player must make **K consecutive correct decisions** to reach the exit (K is configurable, default 8).
- A perfect run (zero mistakes) takes exactly K passes.
- There is no "number of anomalies to find" — the goal is distance-based. A perfect run could theoretically be K clean corridors in a row with zero anomalies.

### Direction

The player always moves "forward." Left and right have no semantic meaning. The corridor extends in one direction from the lobby; after a turn-back, the next corridor extends in the opposite direction. The player cannot build spatial habits around left/right — only forward/backward matter.

---

## The Corridor — Canonical State

The corridor has one fixed layout. Every anomaly is a deviation from this canonical state. This section is the source of truth for what "normal" looks like.

### Geometry

- Side-scrolling 2D corridor, slightly curved (the far end is never fully visible from the entrance)
- Fixed length — always the same, every pass (unless the anomaly IS a length change)
- Low ceiling, oppressive but not crawlspace
- Floor: uneven stone, slightly damp
- Three parallax depth layers:

| Layer | Content | Torch Illumination |
|---|---|---|
| Background | Rough limestone, cracks, moisture stains | Barely reached |
| Midground | Ossuaire walls, brick sections — primary anomaly zone | Primary illumination |
| Foreground | Stone frame edges, partial ceiling | Always partially lit |

### Canonical Objects and Elements

The corridor is divided into zones for reference purposes. Zone positions are relative — "near" means closer to the lobby entrance, "far" means toward the exit end.

**Zone A — First Third:**

| Position | Element | Canonical State |
|---|---|---|
| Floor | Puddles of standing water | Irregular, reflect torchlight |
| Near wall | Red painted arrow | Points toward exit (forward) |
| Far wall | Date carved into stone | "1786" |
| Ceiling | Rusted metal hook | Empty |

**Zone B — Middle Third:**

| Position | Element | Canonical State |
|---|---|---|
| Floor | Broken work lamp | Lying on its side, glass smashed |
| Near wall | Abandoned explorer's backpack | Zip open, near side only |
| Far wall | Row of skulls | Exactly 7, third one slightly forward |
| Ceiling | Electrical cable | Hanging loose, frayed end visible |

**Zone C — Final Third:**

| Position | Element | Canonical State |
|---|---|---|
| Floor | Braided rope | Coiled neatly |
| Near wall | Candle in wall crack | Unlit |
| Far wall | Latin inscription | "MEMENTO MORI", fully legible |
| Ceiling | Work site fluorescent lamp | On, slight flicker |

### Graffiti

Graffiti is part of the canonical state — always present, always in the same positions, always the same content. Graffiti serves as a reference landmark, not a source of confusion. An anomaly involving graffiti (changed, missing, new) is explicitly categorized as such in the anomaly pool.

### Canonical Soundscape

| Sound | Character |
|---|---|
| Water drips | Irregular, from the far end, persistent |
| Footsteps | Wet stone echo, slightly delayed |
| Fluorescent hum | Low, constant, Zone C only |
| Structure creak | Occasional, distant, every ~30 seconds |
| Air current | One cold breath per traversal, random timing |

---

## Anomaly System

### Rules

- Each corridor contains **zero or one** anomaly (50/50 chance).
- All anomalies are **hand-authored** — no procedural generation of anomaly content.
- Each anomaly is tagged with a **sensory channel**: `Visual`, `Audio`, or `Both`.
- Each anomaly has a **difficulty tier** (1 = obvious, 2 = subtle, 3 = ambiguous). Higher tiers are locked until the player has completed N passes (thresholds TBD at playtesting).
- The game tracks which anomalies the player has **discovered** (persistent across sessions). Undiscovered anomalies are prioritized in selection. Once all have been seen, selection uses weighted randomization to avoid immediate repeats.
- Anomaly categories: Physical Objects, Architecture, Light & Shadow, Inscriptions & Graffiti, Audio Only, Presence/Silhouette.

### Anomaly Selection Algorithm

1. Filter the pool by: unlocked difficulty tier (based on passes completed this run) AND compatible sensory channel (based on accessibility mode).
2. From the filtered pool, prioritize anomalies not yet in the player's discovered collection.
3. If all filtered anomalies have been discovered, use weighted random selection (lower weight for recently seen anomalies).
4. Place the selected anomaly in the corridor during generation.

### Anomaly Catalogue

This catalogue will be expanded during development. Initial set from the prototype GDD:

**Category 1 — Physical Objects (Visual)**

| Anomaly | Difficulty |
|---|---|
| Skull missing from its alcove | 1 |
| Candle lit instead of unlit | 1 |
| Backpack moved from canonical position | 2 |
| Only 6 skulls in the row instead of 7 | 2 |
| Candle flame burning upside down | 2 |
| An object appears that wasn't there on the last pass | 3 |
| A second backpack, identical to the player's own | 3 |

**Category 2 — Architecture (Visual)**

| Anomaly | Difficulty |
|---|---|
| Bricked-up doorway now open | 1 |
| Collapsed arch now intact | 1 |
| Corridor appears longer than it should be | 2 |
| Wall crack from last pass has disappeared | 2 |
| Wrong wall texture in a section (stone becomes brick) | 2 |
| Entire corridor is a mirror image of itself | 3 |
| A chamber exists that cannot be here | 3 |

**Category 3 — Light & Shadow (Visual)**

| Anomaly | Difficulty |
|---|---|
| Shadow cast with no light source | 1 |
| Work lamp on when it was broken and dark before | 1 |
| Player's shadow points the wrong direction | 2 |
| Pool of light with no visible source | 2 |
| Shadow of an object that isn't there | 3 |
| The torch illuminates behind the player, not ahead | 3 |

**Category 4 — Inscriptions & Graffiti (Visual)**

| Anomaly | Difficulty |
|---|---|
| Carved date has changed | 1 |
| Directional arrow is reversed | 1 |
| A carved name has subtly changed between passes | 2 |
| French graffiti replaced by unknown language | 2 |
| New message reads "TURN BACK" | 3 |
| Graffiti describes exactly what the player just did | 3 |
| Distance panel displays a negative number | 3 |

**Category 5 — Audio Only (Audio)**

| Anomaly | Difficulty |
|---|---|
| Complete silence where dripping water should be | 1 |
| Footsteps behind the player that stop when they stop | 2 |
| Echo returns slightly too late | 2 |
| Indistinct distant voice where there was none | 2 |
| The distant voice says something recognizable | 3 |
| No sound at all — even footsteps are silent | 3 |

**Category 6 — Presence / Silhouette (Visual)**

Used sparingly. Maximum one per run recommended.

| Anomaly | Difficulty |
|---|---|
| Silhouette at the far end that disappears when approached | 2 |
| Silhouette that doesn't recede as the player advances | 2 |
| Silhouette that mirrors the player's movements exactly | 3 |
| Silhouette present on the return pass but not the initial walk | 3 |
| Silhouette identical to the player, back turned (the double) | 3 |

---

## The Ending

When the player reaches distance 0, a door appears where there was none. Through it, the final corridor looks exactly like the very first pass — clean, relatively bright, familiar.

The player's **double** stands at the far end of this final corridor, back turned.

The player can:
- **Walk forward through it** → screen goes white, then fades to black, then title screen.
- **Turn back** → screen fades directly to black, then title screen.

Neither choice is explained. Neither is "correct." The ambiguity is the point.

---

## The Lobby

- **Physical space:** One full screen width. A zone of rest and information.
- **Always identical** in layout — it is the player's reference anchor.
- **Displays:**
  - **Distance panel:** distance remaining to exit (e.g., "EXIT — 60m"). Resets to max on error.
  - **Anomaly counter:** anomalies correctly identified / total anomalies discovered across all sessions.
- **Contains:**
  - Access to the **anomaly collection menu** (list of all discovered anomalies with visuals/descriptions).
  - The corridor entrance(s) — one direction leads to the preserved previous corridor, the other leads to the next generated corridor.
- **First lobby of a session** doubles as the **main menu** (minimalist, integrated into the world — "Continue" / "New Run" / "Options" / "Quit" presented as in-world elements or subtle UI).

---

## Controls

### Keyboard + Mouse (Primary)
- **WASD / Arrow keys:** Move left/right (forward/backward contextually)
- **Shift:** Run
- **Mouse:** Aim torch (free 2D — horizontal and vertical, can look at ceiling, floor, walls)
- **Escape:** Pause overlay

### Gamepad
- **Left stick:** Move
- **Right stick:** Aim torch
- **A/X button or trigger:** Run
- **Start:** Pause overlay

### Movement Notes
- There is a walk speed and a run speed. Running is always available.
- The game is paced to reward slowness, but never punishes speed mechanically.
- There is no jump. Movement is horizontal only.

---

## Accessibility (Core — Day 1)

Accessibility is not a post-launch feature. It shapes the architecture from the start.

### Three Modes

| Mode | Anomaly Pool | Audio Engine | Visual Engine |
|---|---|---|---|
| Standard | All (Visual + Audio + Both) | Active | Active |
| Deaf | Visual + Both only | Disabled | Active |
| Blind | Audio + Both only | Active | Disabled (or minimal) |

### Deaf Mode
- Sound engine fully disabled.
- All gameplay information is visual.
- Audio-only anomalies are excluded from the pool.
- No captions needed (there is no dialogue).

### Blind Mode
- Visuals disabled or reduced to minimal functional elements.
- Navigation via **spatial audio:**
  - Wall proximity: sound cue intensifies as the player approaches a wall
  - Floor texture: footstep sound changes based on surface
  - Lobby beacon: continuous low hum, always spatially locatable, marks the lobby position
- All anomalies in this mode are audio-based.
- The anomaly pool must contain **enough Audio and Both anomalies** to fill a complete run at every difficulty tier.

### Colorblind Mode
- Alternate color palettes for common colorblind types (protanopia, deuteranopia, tritanopia).
- The game's core palette (warm ochre vs cold blue-grey) should be tested against these.

### Design Constraint
Every anomaly must be tagged `Visual`, `Audio`, or `Both`. The pool must be balanced enough that both Deaf and Blind modes have a complete, satisfying game experience — not a diminished one.

---

## Visual Direction

### Style
- **Side-scrolling 2D** with three parallax layers for depth.
- **Procedurally generated base textures:**
  - Stone surfaces: layered Perlin/Simplex noise (large scale for geological features, fine scale for grain)
  - Brick/mortar patterns: Voronoi noise
  - Generated at startup or first launch, cached for consistency within a session
- **Art style target:** High-contrast ink-wash / lithograph. Dark, organic, slightly printed-looking.
- **Open-source assets** for elements that can't be procedurally generated (specific objects like skulls, backpack, candle, etc.)

### The Torch
- Primary visual mechanic. Follows mouse/right stick in full 2D (up, down, left, right).
- Illuminates a warm, imperfect cone of light. Soft falloff at edges — not a hard circle.
- Implemented via **WGSL shaders**.
- Battery is unlimited. The torch is a tool of focus, not a resource.
- The torch projects light **forward/outward from the player**, keeping the player character in **permanent silhouette** (backlit against their own light).

### The Player Character
- **Silhouette only.** Never detailed, never identifiable. A dark human shape against the torchlight.
- Approximately **1/6 of screen height.**
- Inclusivity by design — no visible gender, race, age, or features. Just a person.

### Color Palette
- **Torch light:** warm ochre, amber
- **Ambient dark:** cold grey-blue, dark brown-grey
- Warmth = safety, cold = uncertainty
- Outside the torch beam, shapes are barely legible — the player can't fully trust peripheral vision.

### UI Philosophy
- **No HUD** except the distance panel and anomaly counter in the lobby.
- No health bar, no minimap, no act markers, no floating text.
- The pause overlay is the only non-diegetic UI element.

---

## Audio Direction

### Approach
- **Procedurally generated ambient soundscape**, inspired by myNoise — layered, continuous, generated from parameters rather than fixed audio files.
- **VFX / one-shot sounds** from open-source libraries (footsteps, drips, creaks, impacts).
- **No composed music.** Everything the player hears should be explainable by the physical space — until an audio anomaly breaks that rule.

### Soundscape Arc
The base soundscape parameters should shift subtly as the player progresses through the run:
- **Early passes:** Neutral, realistic catacomb ambiance. Drips, hum, echo.
- **Mid passes:** Same sounds, but mix shifts — frequencies slightly wrong, silences feel louder.
- **Late passes:** Soundscape becomes unreliable. Audio anomalies are maximally effective here because the player has fully internalized the canonical soundscape.
- **Final corridor:** Near silence. Dripping stopped. Hum gone. Footsteps echo more than they should.

### Spatial Audio
Required for blind mode, beneficial for all modes:
- Sounds have spatial position (left/right based on source location in corridor).
- Footstep echo behavior reflects corridor geometry.
- The lobby beacon hum is always spatially locatable.

---

## Persistence & Save System

### What Persists (Between Sessions)
- **Anomaly collection:** Which anomalies the player has discovered. Stored locally.
- **Settings:** Accessibility mode, audio/visual preferences, control bindings.

### What Does NOT Persist
- **Run progress:** Distance, streak count, current corridor state. Every session starts a fresh run.

### Anomaly Collection Menu
- Accessible from the lobby.
- Displays all discovered anomalies with a visual/description for each.
- Shows a global counter: discovered / total in the game.
- Undiscovered anomalies are shown as locked/hidden entries (so the player knows there's more to find).

---

## Pause System

- **Escape / Start button** triggers a dark overlay.
- Options: Resume, Options (settings), Quit.
- The game world freezes — no audio, no animation.
- Standard pause behavior, nothing integrated into the game world.

---

## Technical Architecture (Bevy)

### Project Structure
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
└── CLAUDE.md           # This file
```

### Bevy States
```
MainMenu → InLobby → InCorridor → InLobby → ... → GameEnd
                ↕
          PauseOverlay (sub-state)
          CollectionMenu (sub-state)
```

### Key Architectural Decisions
- **Bevy States** for high-level transitions (menu, lobby, corridor, end).
- **Sub-states** for pause and collection menu (overlay on top of current state).
- **Input abstraction layer:** All game logic reads from an abstract input system, never directly from keyboard/mouse/gamepad. This makes control remapping and accessibility clean.
- **Anomaly as data:** Each anomaly is a data definition (struct/enum) with tags (channel, difficulty, category). The corridor generator reads this data to place anomalies. No anomaly logic is hard-coded into corridor rendering.
- **Sensory channel filtering** happens at the anomaly selection level, not the rendering level. In deaf mode, audio anomalies are simply never selected. In blind mode, visual anomalies are never selected.

---

## Development Priorities

This is a solo project with no deadlines. Quality over speed. The priorities are:

1. **Core loop first:** Player can walk through a corridor, turn back, reach a lobby, see the distance panel update. No anomalies yet — just the traversal working perfectly.
2. **Canonical corridor:** The corridor renders correctly with all canonical objects in place. Procedural textures working. Torch lighting functional.
3. **Anomaly system:** One anomaly from each category, correctly placed, correctly detected. The selection and tagging system works.
4. **Lobby and progression:** Distance panel, streak logic, reset on error, anomaly counter.
5. **Audio:** Canonical soundscape, spatial audio foundation.
6. **Accessibility modes:** Deaf mode (straightforward — just filter the pool). Blind mode (complex — spatial navigation).
7. **Content expansion:** Fill out the anomaly catalogue. Difficulty tiering. Polish.
8. **Ending sequence:** The double. The final decision. Fade to black.
9. **Persistence:** Save/load anomaly collection. Settings.
10. **Menus:** Main menu integrated into first lobby. Options. Pause overlay.
11. **Polish and playtesting:** Tune streak length, anomaly probability, difficulty curve, corridor walk time.

---

## Configurable Parameters

These values are design levers that should be easy to change during playtesting:

| Parameter | Default | Notes |
|---|---|---|
| `streak_to_win` | 8 | Consecutive correct decisions to reach exit |
| `anomaly_probability` | 0.5 | Chance a corridor contains an anomaly |
| `distance_max` | 80 | Starting/reset distance (display units) |
| `distance_per_correct` | 10 | Distance reduced per correct decision (80/8=10) |
| `walk_speed` | TBD | Base walking speed (pixels/sec or world units/sec) |
| `run_speed` | TBD | Running speed |
| `corridor_length` | TBD | Corridor length in world units |
| `difficulty_tier_thresholds` | [0, N, M] | Passes completed before tier 2/3 anomalies unlock |
| `torch_radius` | TBD | Base radius of torch illumination |
| `torch_falloff` | TBD | Softness of torch edge falloff |

---

## Wiki (Detailed Documentation)

This file is the quick-reference source of truth. For deeper detail, see the project wiki in `wiki/`:

| Document | Covers |
|---|---|
| `game-design.typ` | Full GDD — traversal model, canonical corridor, anomaly catalogue, lobby, ending, controls, accessibility, configurable parameters |
| `technical-design.typ` | Bevy architecture, project structure, state machine, input abstraction, anomaly data model, lighting, audio implementation |
| `art-direction.typ` | Ink-wash/lithograph style, procedural textures (Perlin + Voronoi), torch behavior, player silhouette, color palette, UI philosophy |
| `audio-design.typ` | Procedural soundscape, soundscape arc, spatial audio, blind mode navigation, audio anomaly design |

The wiki compiles to PDF via GitHub Actions and is hosted at: https://vianpyro.github.io/below-the-14th/

When this file and the wiki conflict, **this file wins** — it is updated more frequently during active development.

---

## Conventions for Claude Sessions

- **Always read this file first** when starting a new session on this project.
- **Consult the wiki** for detailed specifications when implementing a specific system.
- **Ask before making design decisions** that aren't covered here. If in doubt, ask.
- **Code in Rust** using Bevy idioms (ECS, systems, components, resources).
- **Comment non-obvious code.** The developer is a Bevy beginner.
- **Test incrementally.** Each feature should be runnable and verifiable before moving to the next.
- **This document evolves.** Update it when design decisions are made or changed during development.
