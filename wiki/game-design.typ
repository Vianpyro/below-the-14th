#import "/wiki/template.typ": *

#show: wiki-page.with(
  title: "Game Design Document",
  subtitle: "Mechanics, Systems, and Content",
  version: "1.0",
)

= Vision

_Below the 14th_ is a short, tightly designed anomaly-detection game set in the catacombs beneath Paris. The player is an urban explorer — a _cataphile_ — trapped in a looping corridor. The only way out is to correctly identify whether each pass through the corridor is normal or contains a single anomaly.

The game draws direct inspiration from _Exit 8_ and _False Mall_, transposed into a side-scrolling, torch-lit catacomb. The torch creates a layer of perceptual tension: the player only ever sees a small cone of light, and must choose where to aim it.

The target experience is 30–45 minutes for an average first playthrough.

== Player Experience

Three emotional pillars define the game:

*Enquiry and discovery.* The corridor rewards attention. Players who notice the third skull, the direction of an arrow, the way a shadow falls will feel genuinely clever. The "I see you" moment when an anomaly reveals itself is the primary reward.

*Slow-burning paranoia.* Not jump scares. Not gore. Tension through accumulation — a corridor that becomes incrementally less reliable, a space where the player's own memory becomes uncertain. The fear is cognitive, not visceral.

*Accessibility across player types.* Puzzle players and horror players should both be comfortable. The game never punishes passively — it just doesn't reward inattention. No monster, no countdown. Just the corridor and the player's read of it.


= Core Traversal Model

#callout(title: "Critical System", icon: "◆")[
  This is the most important system in the game. Every other system depends on it. Read carefully.
]

== The World Structure

The world is a linear sequence generated on the fly:

#align(center)[
  #set text(size: 11pt, fill: colors.accent)
  *lobby → corridor → lobby → corridor → lobby ...*
]

There is no fixed map. Lobbies and corridors do not have persistent positions in space — they are created ahead of the player and destroyed behind them as needed.

== The First Lobby

The very first lobby of a run is unique: it has *two corridors*, one on each side, generated independently. Each has its own 50/50 anomaly chance. The player chooses a direction — this is the only moment in the game where a directional choice exists. After this first choice, all subsequent lobbies follow the standard model.

== How a Pass Works

+ The player is in a *lobby*. The lobby displays the distance panel (distance remaining + anomalies found/total discovered). The player can stay as long as they want.
+ The player walks into the *corridor*. One direction leads to the preserved previous corridor (for verification), the other leads to the next generated corridor. The corridor has a fixed, canonical length — always the same.
+ The corridor either contains *one anomaly* or *no anomaly* (50% chance each, determined randomly at generation).
+ The player makes a decision:

=== Option A — Keep Walking (Reach the Far End)

- Corridor was clean → #tag("correct") Distance reduced. New lobby generated at far end. Old corridor remains accessible behind the player.
- Corridor had an anomaly the player missed → #tag("incorrect", color: rgb("#c04040")) Progress resets. New lobby shows the reset. Old corridor remains accessible so the player can go back and find what they missed.

=== Option B — Turn Back (Return to Lobby)

- Corridor had an anomaly → #tag("correct") Distance reduced. Corridor remains intact behind the player for re-entry. New corridor generated in opposite direction when ready.
- Corridor was clean → #tag("incorrect", color: rgb("#c04040")) Progress resets. Corridor remains accessible so the player sees there was nothing wrong.

== Corridor Preservation

#callout(title: "Critical Rule")[
  The last traversed corridor is *always preserved* until the player commits to the next one. This serves the learning loop — the player can always go back and verify their decision. The old corridor is only destroyed when the player crosses the threshold into a new corridor.
]

== Progression

- Each correct decision reduces the distance to the exit by a fixed amount.
- Each incorrect decision *resets distance to maximum* (back to square one).
- The player must make *K consecutive correct decisions* to reach the exit (K is configurable, default 8).
- A perfect run takes exactly K passes. There is no "number of anomalies to find" — a perfect run could theoretically be K clean corridors with zero anomalies.

== Direction

The player always moves "forward." Left and right have no semantic meaning. The corridor extends in one direction from the lobby; after a turn-back, the next corridor extends in the opposite direction. No spatial habits around left/right — only forward/backward matter.


= The Corridor — Canonical State

The corridor has one fixed layout. Every anomaly is a deviation from this canonical state. This section is the source of truth for what "normal" looks like.

== Geometry

- Side-scrolling 2D, slightly curved (far end never fully visible from entrance)
- Fixed length — always the same, every pass (unless the anomaly IS a length change)
- Low ceiling, oppressive but not crawlspace
- Floor: uneven stone, slightly damp

== Parallax Depth Layers

#table(
  columns: (1fr, 2fr, 1.5fr),
  [Layer], [Content], [Torch Illumination],
  [Background], [Rough limestone, cracks, moisture stains], [Barely reached],
  [Midground], [Ossuaire walls, brick sections — primary anomaly zone], [Primary illumination],
  [Foreground], [Stone frame edges, partial ceiling], [Always partially lit],
)

== Zone A — First Third

#table(
  columns: (0.8fr, 1.2fr, 2fr),
  [Position], [Element], [Canonical State],
  [Floor], [Puddles of standing water], [Irregular, reflect torchlight],
  [Near wall], [Red painted arrow], [Points toward exit (forward)],
  [Far wall], [Date carved into stone], ["1786"],
  [Ceiling], [Rusted metal hook], [Empty],
)

== Zone B — Middle Third

#table(
  columns: (0.8fr, 1.2fr, 2fr),
  [Position], [Element], [Canonical State],
  [Floor], [Broken work lamp], [Lying on its side, glass smashed],
  [Near wall], [Abandoned explorer's backpack], [Zip open, near side only],
  [Far wall], [Row of skulls], [Exactly 7, third one slightly forward],
  [Ceiling], [Electrical cable], [Hanging loose, frayed end visible],
)

== Zone C — Final Third

#table(
  columns: (0.8fr, 1.2fr, 2fr),
  [Position], [Element], [Canonical State],
  [Floor], [Braided rope], [Coiled neatly],
  [Near wall], [Candle in wall crack], [Unlit],
  [Far wall], [Latin inscription], ["MEMENTO MORI", fully legible],
  [Ceiling], [Work site fluorescent lamp], [On, slight flicker],
)

== Graffiti

Graffiti is part of the canonical state — always present, always in the same positions, always the same content. An anomaly involving graffiti (changed, missing, new) is explicitly categorized as such in the anomaly pool. Graffiti serves as a reference landmark, never a source of confusion.

== Canonical Soundscape

#table(
  columns: (1fr, 2.5fr),
  [Sound], [Character],
  [Water drips], [Irregular, from the far end, persistent],
  [Footsteps], [Wet stone echo, slightly delayed],
  [Fluorescent hum], [Low, constant, Zone C only],
  [Structure creak], [Occasional, distant, every \~30 seconds],
  [Air current], [One cold breath per traversal, random timing],
)


= Anomaly System

== Core Rules

- Each corridor contains *zero or one* anomaly (50/50 chance).
- All anomalies are *hand-authored* — no procedural generation of anomaly content.
- Each anomaly is tagged with a *sensory channel*: #tag("visual") #tag("audio") or #tag("both")
- Each anomaly has a *difficulty tier*: #tag("tier 1", color: rgb("#60a060")) #tag("tier 2", color: rgb("#d4a048")) #tag("tier 3", color: rgb("#c04040"))
- Higher tiers are locked until the player has completed N passes (thresholds TBD at playtesting).
- The game tracks which anomalies the player has *discovered* (persistent across sessions).

== Selection Algorithm

+ Filter the pool by: unlocked difficulty tier (based on passes completed this run) AND compatible sensory channel (based on accessibility mode).
+ Prioritize anomalies not yet in the player's discovered collection.
+ If all filtered anomalies have been discovered, use weighted random selection (lower weight for recently seen anomalies).
+ Place the selected anomaly in the corridor during generation.

== Anomaly Catalogue

=== Category 1 — Physical Objects #tag("visual")

#table(
  columns: (3fr, 0.8fr),
  [Anomaly], [Difficulty],
  [Skull missing from its alcove], [#tag("tier 1", color: rgb("#60a060"))],
  [Candle lit instead of unlit], [#tag("tier 1", color: rgb("#60a060"))],
  [Backpack moved from canonical position], [#tag("tier 2", color: rgb("#d4a048"))],
  [Only 6 skulls in the row instead of 7], [#tag("tier 2", color: rgb("#d4a048"))],
  [Candle flame burning upside down], [#tag("tier 2", color: rgb("#d4a048"))],
  [An object appears that wasn't there on the last pass], [#tag("tier 3", color: rgb("#c04040"))],
  [A second backpack, identical to the player's own], [#tag("tier 3", color: rgb("#c04040"))],
)

=== Category 2 — Architecture #tag("visual")

#table(
  columns: (3fr, 0.8fr),
  [Anomaly], [Difficulty],
  [Bricked-up doorway now open], [#tag("tier 1", color: rgb("#60a060"))],
  [Collapsed arch now intact], [#tag("tier 1", color: rgb("#60a060"))],
  [Corridor appears longer than it should be], [#tag("tier 2", color: rgb("#d4a048"))],
  [Wall crack from last pass has disappeared], [#tag("tier 2", color: rgb("#d4a048"))],
  [Wrong wall texture in a section (stone becomes brick)], [#tag("tier 2", color: rgb("#d4a048"))],
  [Entire corridor is a mirror image of itself], [#tag("tier 3", color: rgb("#c04040"))],
  [A chamber exists that cannot be here], [#tag("tier 3", color: rgb("#c04040"))],
)

=== Category 3 — Light & Shadow #tag("visual")

#table(
  columns: (3fr, 0.8fr),
  [Anomaly], [Difficulty],
  [Shadow cast with no light source], [#tag("tier 1", color: rgb("#60a060"))],
  [Work lamp on when it was broken and dark before], [#tag("tier 1", color: rgb("#60a060"))],
  [Player's shadow points the wrong direction], [#tag("tier 2", color: rgb("#d4a048"))],
  [Pool of light with no visible source], [#tag("tier 2", color: rgb("#d4a048"))],
  [Shadow of an object that isn't there], [#tag("tier 3", color: rgb("#c04040"))],
  [The torch illuminates behind the player, not ahead], [#tag("tier 3", color: rgb("#c04040"))],
)

=== Category 4 — Inscriptions & Graffiti #tag("visual")

#table(
  columns: (3fr, 0.8fr),
  [Anomaly], [Difficulty],
  [Carved date has changed], [#tag("tier 1", color: rgb("#60a060"))],
  [Directional arrow is reversed], [#tag("tier 1", color: rgb("#60a060"))],
  [A carved name has subtly changed between passes], [#tag("tier 2", color: rgb("#d4a048"))],
  [French graffiti replaced by unknown language], [#tag("tier 2", color: rgb("#d4a048"))],
  [New message reads "TURN BACK"], [#tag("tier 3", color: rgb("#c04040"))],
  [Graffiti describes exactly what the player just did], [#tag("tier 3", color: rgb("#c04040"))],
  [Distance panel displays a negative number], [#tag("tier 3", color: rgb("#c04040"))],
)

=== Category 5 — Audio Only #tag("audio")

#table(
  columns: (3fr, 0.8fr),
  [Anomaly], [Difficulty],
  [Complete silence where dripping water should be], [#tag("tier 1", color: rgb("#60a060"))],
  [Footsteps behind the player that stop when they stop], [#tag("tier 2", color: rgb("#d4a048"))],
  [Echo returns slightly too late], [#tag("tier 2", color: rgb("#d4a048"))],
  [Indistinct distant voice where there was none], [#tag("tier 2", color: rgb("#d4a048"))],
  [The distant voice says something recognizable], [#tag("tier 3", color: rgb("#c04040"))],
  [No sound at all — even footsteps are silent], [#tag("tier 3", color: rgb("#c04040"))],
)

=== Category 6 — Presence / Silhouette #tag("visual")

#callout(title: "Usage Constraint")[
  Used sparingly. Maximum one per run recommended.
]

#table(
  columns: (3fr, 0.8fr),
  [Anomaly], [Difficulty],
  [Silhouette at the far end that disappears when approached], [#tag("tier 2", color: rgb("#d4a048"))],
  [Silhouette that doesn't recede as the player advances], [#tag("tier 2", color: rgb("#d4a048"))],
  [Silhouette that mirrors the player's movements exactly], [#tag("tier 3", color: rgb("#c04040"))],
  [Silhouette present on the return pass but not the initial walk], [#tag("tier 3", color: rgb("#c04040"))],
  [Silhouette identical to the player, back turned (the double)], [#tag("tier 3", color: rgb("#c04040"))],
)


= The Lobby

== Physical Space

The lobby is one full screen width — a zone of rest and information. It is *always identical* in layout. It is the player's reference anchor.

== Displays

- *Distance panel:* distance remaining to exit (e.g., "EXIT — 60m"). Resets to max on error.
- *Anomaly counter:* anomalies correctly identified / total anomalies discovered across all sessions.

== Contains

- Access to the *anomaly collection menu* (list of all discovered anomalies with visuals and descriptions, undiscovered shown as locked entries).
- The corridor entrance(s): one direction leads to the preserved previous corridor, the other to the next generated corridor.
- In the *first lobby of a session*, the main menu is integrated into the world (Continue / New Run / Options / Quit as in-world elements or subtle UI).


= The Ending

When the player reaches distance 0, a door appears where there was none. Through it, the final corridor looks exactly like the very first pass — clean, relatively bright, familiar.

The player's *double* stands at the far end of this final corridor, back turned.

- *Walk forward through it* → screen goes white, then fades to black, then title screen.
- *Turn back* → screen fades directly to black, then title screen.

Neither choice is explained. Neither is "correct." The ambiguity is the point.


= Controls

== Keyboard + Mouse (Primary)

#table(
  columns: (1.2fr, 2.5fr),
  [Input], [Action],
  [WASD / Arrow keys], [Move left/right (forward/backward contextually)],
  [Shift], [Run],
  [Mouse], [Aim torch (free 2D — horizontal and vertical)],
  [Escape], [Pause overlay],
)

== Gamepad

#table(
  columns: (1.2fr, 2.5fr),
  [Input], [Action],
  [Left stick], [Move],
  [Right stick], [Aim torch],
  [A/X button or trigger], [Run],
  [Start], [Pause overlay],
)

== Movement Notes

- Walk speed and run speed. Running is always available.
- The game rewards slowness but never punishes speed mechanically.
- No jump. Movement is horizontal only.


= Accessibility

#callout(title: "Design Principle")[
  Accessibility is not a post-launch feature. It shapes the architecture from day one.
]

== Three Modes

#table(
  columns: (1fr, 1.5fr, 1fr, 1fr),
  [Mode], [Anomaly Pool], [Audio Engine], [Visual Engine],
  [Standard], [All (Visual + Audio + Both)], [Active], [Active],
  [Deaf], [Visual + Both only], [Disabled], [Active],
  [Blind], [Audio + Both only], [Active], [Disabled / minimal],
)

== Deaf Mode

Sound engine fully disabled. All gameplay information is visual. Audio-only anomalies are excluded from the pool. No captions needed (there is no dialogue).

== Blind Mode

Visuals disabled or reduced to minimal functional elements. Navigation via *spatial audio*:
- *Wall proximity:* sound cue intensifies as the player approaches a wall
- *Floor texture:* footstep sound changes based on surface
- *Lobby beacon:* continuous low hum, always spatially locatable

All anomalies in this mode are audio-based. The anomaly pool must contain enough Audio and Both anomalies to fill a complete run at every difficulty tier.

== Colorblind Mode

Alternate color palettes for protanopia, deuteranopia, and tritanopia. The core palette (warm ochre vs cold blue-grey) should be tested against these.

== Design Constraint

Every anomaly must be tagged #tag("visual"), #tag("audio"), or #tag("both"). The pool must be balanced enough that Deaf and Blind modes each have a complete, satisfying game experience — not a diminished one.


= Persistence & Save System

== What Persists (Between Sessions)

- *Anomaly collection:* which anomalies the player has discovered. Stored locally.
- *Settings:* accessibility mode, audio/visual preferences, control bindings.

== What Does NOT Persist

- *Run progress:* distance, streak count, current corridor state. Every session starts a fresh run.

== Anomaly Collection Menu

- Accessible from the lobby.
- Displays all discovered anomalies with a visual/description for each.
- Global counter: discovered / total in the game.
- Undiscovered anomalies shown as locked/hidden entries.


= Pause System

*Escape / Start button* triggers a dark overlay. Options: Resume, Options (settings), Quit. The game world freezes — no audio, no animation. Standard pause behavior.


= Configurable Parameters

These values are design levers. They should be easy to change during playtesting.

#table(
  columns: (1.5fr, 0.8fr, 2.5fr),
  [Parameter], [Default], [Notes],
  [`streak_to_win`], [8], [Consecutive correct decisions to reach exit],
  [`anomaly_probability`], [0.5], [Chance a corridor contains an anomaly],
  [`distance_max`], [80], [Starting/reset distance (display units)],
  [`distance_per_correct`], [10], [Distance reduced per correct decision],
  [`walk_speed`], [TBD], [Base walking speed],
  [`run_speed`], [TBD], [Running speed],
  [`corridor_length`], [TBD], [Corridor length in world units],
  [`difficulty_tier_thresholds`], [\[0, N, M\]], [Passes before tier 2/3 unlock],
  [`torch_radius`], [TBD], [Base radius of torch illumination],
  [`torch_falloff`], [TBD], [Softness of torch edge falloff],
)
