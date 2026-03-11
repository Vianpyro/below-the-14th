# Game Design Document — *Below the 14th* (working title)

> *"You came looking for a way through. You're not sure that still exists."*

**Version:** 0.1 — Pre-production  
**Genre:** Psychological puzzle / anomaly detection  
**Platform:** PC  
**Target playtime:** 30–45 minutes  
**Engine:** Bevy (Rust)

---

## Table of Contents

1. [Vision](#1-vision)
2. [Player Experience](#2-player-experience)
3. [Core Concept](#3-core-concept)
4. [The Setting](#4-the-setting)
5. [The Character](#5-the-character)
6. [Core Game Loop](#6-core-game-loop)
7. [Mechanics in Detail](#7-mechanics-in-detail)
8. [The Reference Corridor](#8-the-reference-corridor)
9. [Anomaly Catalogue](#9-anomaly-catalogue)
10. [Act Structure & Level Sequence](#10-act-structure--level-sequence)
11. [Narrative Design](#11-narrative-design)
12. [Audio Design](#12-audio-design)
13. [Visual Direction](#13-visual-direction)
14. [Out of Scope](#14-out-of-scope)

---

## 1. Vision

*Below the 14th* is a short, tightly designed anomaly-detection game about being lost underground and slowly realizing the rules of the place you're trapped in don't apply anymore.

The player isn't a hero. They're just someone who went somewhere they shouldn't have, and now needs to pay very close attention to get out.

The game draws direct inspiration from *Exit 8* and *False Mall* — the elegance of movement-as-decision, and the mounting unease of a space that looks familiar but isn't quite right. It transposes that formula into a side-scrolling, torch-lit catacomb, adding a layer of perceptual tension that comes from only ever seeing a small circle of light at a time.

The goal is simple to describe and hard to master: **walk through the corridor, decide whether something is wrong, and act on that decision.** Everything else is texture on top of that.

---

## 2. Player Experience

Three things should define how a player feels at any given moment:

**Enquiry and discovery.** The corridor rewards attention. Players who look carefully — who notice the third skull, the direction of an arrow, the way a shadow falls — will feel genuinely clever. That feeling of "I see you" when an anomaly reveals itself is the game's primary reward.

**Slow-burning paranoia.** Not jump scares. Not gore. The game earns its tension through accumulation — a world that gets incrementally less reliable, a corridor that seems to remember every time you got it wrong. The fear is cognitive, not visceral. Something is off, and the longer you're down here, the harder it is to remember what "normal" looked like.

**Accessibility across player types.** Puzzle players and horror players should both be comfortable here. The game never punishes passively — it just doesn't reward inattention. There's no monster that kills you. There's no countdown. There's just the corridor, and your read of it.

---

## 3. Core Concept

The player is trapped in a looping catacomb corridor. The only way forward is to correctly identify a set number of anomalies — or correctly recognize when there are none. Every mistake resets progress and sends them back to the beginning of the corridor, which returns slightly changed.

The central tension lives in the decision point: **keep walking, or turn back?**

Walking forward means "everything is normal here."  
Turning back means "something is wrong."

Both can be right. Both can be wrong. And the cost of being wrong compounds over time.

---

## 4. The Setting

The Paris Catacombs — specifically, a restricted section that doesn't appear on any map. The historical catacombs are a real labyrinth beneath the city, genuinely dangerous and genuinely disorienting. People have gotten lost there. That real-world context gives the game's premise immediate credibility without needing to explain it.

The corridor itself is narrow, slightly curved (you can never see the far end in full), and built in layers: rough-hewn limestone in the back, sections of old brick, and an ossuaire lining — rows of bones and skulls arranged by hands long gone. It's a space that is simultaneously archaeological and deeply human.

The player only ever sees what their torch illuminates. The rest is dark.

---

## 5. The Character

An urban explorer — a *cataphile* — who entered the restricted zones alone and has clearly been down here longer than intended. They have no special skills. They're not brave in any cinematic sense. They're just someone who knows how to pay attention and is trying very hard not to panic.

The character is never described in dialogue (there is no dialogue). Their presence is implied through their equipment — a backpack visible on the floor somewhere in the corridor, the tools of their trade — and through the fact that they keep moving forward.

The player never sees them directly. They *are* them.

---

## 6. Core Game Loop

```
Enter the corridor
        │
        ▼
FIRST HALF — "The Read"
Walk through, memorize the space.
No anomalies can occur here.
        │
        ▼
MIDPOINT MARKER
A subtle environmental cue signals the threshold:
a wall-mounted work lamp, a change in floor texture.
        │
        ▼
SECOND HALF — "The Decision"
An anomaly may or may not be present.
Compare what you're seeing to what you memorized.
        │
   ┌────┴────┐
   ▼         ▼
TURN BACK  KEEP WALKING
   │         │
   ▼         ▼
Anomaly    Anomaly
present?   present?
 YES  NO    NO   YES
  │    │    │     │
 -20m Reset -20m Reset
```

**The distance panel.** At the start of each corridor pass, a wall-mounted sign reads **"EXIT — 80m"**. Every correct decision (turning back on an anomaly, or walking through a clean corridor) reduces it by 20m. Four correct consecutive decisions open the way forward. Any mistake resets it to 80m.

**The false positive.** Turning back on a normal corridor is penalized just as harshly as missing an anomaly. The game respects both directions of error.

**Consecutive, not cumulative.** Progress can't be banked. Four correct calls in a row, or nothing. This is what creates the tension of being at 20m — one wrong read and you're back at 80.

---

## 7. Mechanics in Detail

### The Torch

The torch follows the mouse cursor. It illuminates a circular area around the point the player aims at. The rest of the corridor is dark.

The battery is unlimited. Frustration from fumbling in the dark is not interesting — tension from *choosing where to look* is. The torch is a tool of focus, not a resource to manage.

### Movement

Standard 2D side-scrolling. The player moves left (back) or right (forward). The corridor is approximately 15–20 seconds long at a comfortable walk.

There is no run. Rushing doesn't help. The game is explicitly paced to reward slowness.

### The Decision

There is no "report anomaly" button. The decision is entirely physical:

- Walk forward past the midpoint and keep going → "Nothing is wrong here."
- Turn around and walk back to the entrance → "Something is wrong here."

This is the *Exit 8* model transposed into a side-scroller. The elegance is that the mechanic requires no UI and no explanation.

### Failure State

Missing an anomaly or flagging a clean corridor sends the player back to the corridor entrance. The distance panel resets. The corridor regenerates — same geometry, but small ambient details shift. Graffiti accumulates. The mood decays.

There is no game over. There is only being here for longer.

---

## 8. The Reference Corridor

This is the canonical "normal" state of the corridor. Every anomaly is a deviation from this document. Level designers and developers should treat this as the source of truth.

### Geometry

A slightly curved corridor, curving gently to the right. The far end is never fully visible. Ceiling is low — oppressive but not crawlspace low. Floor is uneven stone, slightly damp.

The corridor has three depth layers for parallax:

| Layer | Content | Torch Illumination |
|---|---|---|
| Background | Rough limestone, cracks, moisture stains | Barely reaches here |
| Midground | Ossuaire walls, brick sections — main anomaly zone | Primary illumination |
| Foreground | Stone frame edges, partial ceiling | Always partially lit |

### Zone A — First Third (The Read)

| Position | Element | Canonical State |
|---|---|---|
| Floor | Puddles of standing water | Irregular, reflect torchlight |
| Left wall | Red painted arrow | Points right (toward exit) |
| Right wall | Date carved into stone | **"1786"** |
| Ceiling | Rusted metal hook | Empty |

### Zone B — Midpoint Marker

| Position | Element | Canonical State |
|---|---|---|
| Floor | Broken work lamp | Lying on its side, glass smashed |
| Left wall | Abandoned explorer's backpack | Zip open, left side only |
| Right wall | Row of skulls | **Exactly 7**, third one slightly forward |
| Ceiling | Electrical cable | Hanging loose, frayed end visible |

### Zone C — Second Half (The Decision)

| Position | Element | Canonical State |
|---|---|---|
| Floor | Braided rope | Coiled neatly |
| Left wall | Candle in wall crack | **Unlit** |
| Right wall | Latin inscription | **"MEMENTO MORI"**, fully legible |
| Ceiling | Work site fluorescent lamp | **On**, slight flicker |

### The Six Immutable Rules

These never change — until Act 3 deliberately breaks them:

1. The arrow always points toward the exit
2. The candle is always unlit
3. The fluorescent lamp is always on
4. There are always exactly 7 skulls in Zone B
5. The backpack is always on the left wall
6. "MEMENTO MORI" is always fully legible

When an immutable rule breaks, it signals to the attentive player that something fundamental has shifted. These moments are reserved for Act 3 and used sparingly.

### Canonical Soundscape

| Sound | Character |
|---|---|
| Water drips | Irregular, coming from the right, persistent |
| Footsteps | Wet stone echo, slightly delayed |
| Fluorescent hum | Low, constant, Zone C only |
| Structure creak | Occasional, distant, every ~30 seconds |
| Air current | One cold breath per traversal, random timing |

---

## 9. Anomaly Catalogue

Anomalies are classified on two axes:

**Subtlety:** Obvious → Subtle → Ambiguous  
**Nature:** Physical (something moved) / Logical (something is impossible) / Temporal (something behaves wrongly)

Actes 1–2 use Obvious and Subtle anomalies. Act 3 introduces Ambiguous and breaks the Immutable Rules. Act 4 operates at a meta level.

### Category 1 — Physical Objects

| Anomaly | Subtlety | Nature | Act |
|---|---|---|---|
| Skull missing from its alcove | Obvious | Physical | 1 |
| Candle lit instead of unlit | Obvious | Physical | 1 |
| Backpack moved one meter from canonical position | Subtle | Physical | 2 |
| Only 6 skulls in the row instead of 7 | Subtle | Physical | 2 |
| Candle flame burning upside down | Subtle | Logical | 2 |
| An object appears that wasn't there on the last pass | Ambiguous | Temporal | 3 |
| A second backpack, identical to the player's own | Ambiguous | Logical | 3 |

### Category 2 — Architecture

| Anomaly | Subtlety | Nature | Act |
|---|---|---|---|
| Bricked-up doorway now open | Obvious | Physical | 1 |
| Collapsed arch now intact | Obvious | Physical | 1 |
| Corridor appears longer than it should be | Subtle | Logical | 2 |
| Wall crack from last pass has disappeared | Subtle | Physical | 2 |
| Wrong wall texture in a section (stone becomes brick) | Subtle | Physical | 2 |
| Entire corridor is a mirror image of itself | Ambiguous | Logical | 3 |
| A chamber exists that cannot be here | Ambiguous | Logical | 3 |

### Category 3 — Light and Shadow

| Anomaly | Subtlety | Nature | Act |
|---|---|---|---|
| Shadow cast with no light source to explain it | Obvious | Logical | 1 |
| Work lamp on when it was broken and dark before | Obvious | Physical | 1 |
| Player's own shadow points the wrong direction | Subtle | Logical | 2 |
| Pool of light with no visible source | Subtle | Logical | 2 |
| Shadow of an object that isn't there | Ambiguous | Logical | 3 |
| The torch illuminates behind the player, not ahead | Ambiguous | Temporal | 3 |

### Category 4 — Inscriptions and Graffiti

| Anomaly | Subtlety | Nature | Act |
|---|---|---|---|
| Carved date has changed | Obvious | Temporal | 1 |
| Directional arrow is reversed | Obvious | Physical | 1 |
| A carved name has subtly changed between passes | Subtle | Temporal | 2 |
| French graffiti replaced by an unknown language | Subtle | Logical | 2 |
| New message reads "TURN BACK" | Ambiguous | Temporal | 3 |
| Graffiti describes exactly what the player just did | Ambiguous | Logical | 3 |
| Distance panel displays a negative number | Ambiguous | Logical | 3 |

### Category 5 — Audio Only

These anomalies have no visual component. The player must have internalized the canonical soundscape to detect them.

| Anomaly | Subtlety | Nature | Act |
|---|---|---|---|
| Complete silence where dripping water should be | Obvious | Physical | 1 |
| Footsteps behind the player that stop when they stop | Obvious | Logical | 2 |
| Echo returns slightly too late | Subtle | Logical | 2 |
| Indistinct distant voice where there was none | Subtle | Physical | 2 |
| The distant voice says something recognizable | Ambiguous | Logical | 3 |
| No sound at all — even footsteps are silent | Ambiguous | Temporal | 3 |

### Category 6 — Presence / Silhouette

Used sparingly. Maximum one per act. Always positioned in the second half of the corridor.

| Anomaly | Subtlety | Nature | Act |
|---|---|---|---|
| Silhouette at the far end that disappears when approached | Obvious | Physical | 2 |
| Silhouette that doesn't recede as the player advances | Subtle | Logical | 2 |
| Silhouette that mirrors the player's movements exactly | Ambiguous | Logical | 3 |
| Silhouette present on the return pass but not the initial walk | Ambiguous | Temporal | 3 |
| Silhouette identical to the player, back turned | Ambiguous | Logical | 4 |

The final entry — the player's double — is reserved exclusively for Act 4. It is the game's thesis statement rendered as an image: *maybe you are the anomaly.*

---

## 10. Act Structure & Level Sequence

Total: 38 corridor passes across 4 acts. 13 of those passes are clean (no anomaly). This ~34% clean rate mirrors *Exit 8* and is intentional — it keeps the player from defaulting to "always turn back."

### Act 1 — "The Entrance" (~5 min, 8 passes)

The tutorial that doesn't announce itself. Anomalies are obvious, one per pass, each from a different category. Three clean passes teach the player that doing nothing is also a valid answer.

The fluorescent work lamps are still on. The corridor is relatively well-lit.

| Pass | State | Anomaly |
|---|---|---|
| 1 | **CLEAN** | — |
| 2 | Anomaly | **[OBJECTS]** Skull missing from Zone B |
| 3 | **CLEAN** | — |
| 4 | Anomaly | **[ARCHITECTURE]** Bricked doorway now open |
| 5 | Anomaly | **[INSCRIPTIONS]** Arrow reversed |
| 6 | **CLEAN** | — |
| 7 | Anomaly | **[LIGHT]** Shadow with no source |
| 8 | **CLEAN** | Transition — work lamps flicker out one by one |

*End of Act 1:* The player is left with only their torch.

---

### Act 2 — "The Depths" (~10 min, 12 passes)

Anomalies become subtle. Audio anomalies are introduced. The first silhouette appears at the very end of the act, functioning as a hard punctuation mark before the corridor resets unexpectedly.

| Pass | State | Anomaly |
|---|---|---|
| 9 | **CLEAN** | — |
| 10 | Anomaly | **[OBJECTS]** 6 skulls instead of 7 |
| 11 | Anomaly | **[AUDIO]** Dripping water has stopped entirely |
| 12 | **CLEAN** | — |
| 13 | Anomaly | **[ARCHITECTURE]** Wall crack from last pass is gone |
| 14 | Anomaly | **[INSCRIPTIONS]** Carved name has subtly changed |
| 15 | **CLEAN** | — |
| 16 | Anomaly | **[LIGHT]** Player's shadow points the wrong way |
| 17 | Anomaly | **[OBJECTS]** Candle burning upside down |
| 18 | **CLEAN** | — |
| 19 | Anomaly | **[AUDIO]** Footsteps behind the player |
| 20 | Anomaly | **[PRESENCE]** Silhouette at corridor end, disappears |

*End of Act 2:* The distance panel reaches 20m — then resets to 80m with no mistake made. Something external has intervened.

---

### Act 3 — "The Degradation" (~15 min, 14 passes)

The longest and most demanding act. Anomalies become ambiguous. The Immutable Rules begin to break. The graffiti on the walls accumulates — evidence of others who were here, who didn't get out. The line between normal and wrong becomes genuinely unclear.

| Pass | State | Anomaly |
|---|---|---|
| 21 | **CLEAN** | New graffiti visible on walls (environmental, not an anomaly) |
| 22 | Anomaly | **[INSCRIPTIONS]** "TURN BACK" appears on wall |
| 23 | Anomaly | **[ARCHITECTURE]** Corridor seems longer |
| 24 | **CLEAN** | — |
| 25 | Anomaly | **[LIGHT]** Pool of light, no source |
| 26 | Anomaly | **[OBJECTS]** Second backpack, identical to player's |
| 27 | Anomaly | **[AUDIO]** Echo returns too late |
| 28 | **CLEAN** | *Immutable Rule broken:* the candle is lit |
| 29 | Anomaly | **[ARCHITECTURE]** Corridor is its own mirror image |
| 30 | Anomaly | **[INSCRIPTIONS]** Distance panel shows negative number |
| 31 | Anomaly | **[AUDIO]** Distant voice says something recognizable |
| 32 | **CLEAN** | — |
| 33 | Anomaly | **[LIGHT]** Torch illuminates behind the player |
| 34 | Anomaly | **[PRESENCE]** Silhouette mirrors player's movements |

*End of Act 3:* Distance panel reads "EXIT — 0m." A door appears where there was no door.

---

### Act 4 — "The Exit" (~5 min, 4 passes)

Short. Almost silent. The corridor looks exactly like Act 1 — clean, relatively bright, familiar. But the player has seen too much to trust that. The graffiti from all previous passes lines the walls. The accumulated record of everyone who was here before.

| Pass | State | Anomaly |
|---|---|---|
| 35 | **CLEAN** | Corridor identical to Pass 1. Uncannily so. |
| 36 | Anomaly | **[INSCRIPTIONS]** Graffiti describes what the player just did |
| 37 | **CLEAN** | — |
| 38 | Anomaly | **[PRESENCE]** Player's double, back turned, at corridor end |

*The Final Decision:* The player reaches their double. They can walk forward (through it) or turn back. Neither choice is explained. The game ends either way.

---

## 11. Narrative Design

There is no written story. There is no dialogue, no journal entries, no cutscenes.

The narrative emerges entirely from environmental accumulation:

**The graffiti.** Other explorers left marks. Arrows, names, dates, warnings. As the game progresses, new marks appear — more desperate in tone, less confident in direction. Some point toward the exit. Some point away from it. The player begins to wonder how long those people were here before they stopped marking walls.

**The backpack.** The abandoned pack in Zone B never changes. It was here before the player arrived. It has been here a long time.

**The distance panel.** It is supposed to tell you how far you are from the exit. By Act 3, it has begun to lie.

**The double.** The final image of the game is a figure that looks exactly like the player, standing at the end of the corridor, back turned. The player has to decide whether that is the anomaly, or whether they are.

The game asks one question and doesn't answer it: *how long have you actually been down here?*

---

## 12. Audio Design

Audio serves two functions: establishing the canonical soundscape that anomalies can break, and supporting the emotional arc of each act.

**Act 1:** Ambient, almost neutral. The drips, the hum, the echo. Familiar underground sounds. The player should feel like they're actually in a catacomb, not a horror game.

**Act 2:** The same sounds, but the mix shifts slightly. The hum gets a frequency that's just slightly wrong. Silence becomes louder when it occurs.

**Act 3:** The soundscape becomes unreliable. Audio anomalies here are the most disturbing because the player has fully internalized what this place should sound like. Anything that deviates from that is deeply wrong.

**Act 4:** Near silence. The dripping has stopped. The hum is gone. Footsteps echo more than they should, as if the space has gotten larger.

There is no score. No composed music. Everything the player hears should be explainable by the space — until it isn't.

---

## 13. Visual Direction

**Side-scrolling 2D**, with three parallax layers creating a sense of depth without requiring 3D assets.

**The torch** is the primary visual mechanic. It casts a warm, imperfect cone of light that follows the mouse. The falloff is soft at the edges — not a hard circle, but a gradual fade into darkness. The rest of the corridor is not black, but very dark brown-grey. Shapes are barely legible. The player can't quite trust what they see outside the torch beam.

**Color palette:** Warm ochre and amber in the torch light. Cold grey-blue in the ambient dark. The contrast is intentional — warmth is safety, cold is uncertainty.

**The ossuaire walls** are a key visual anchor. The rows of skulls are regular, deliberate, almost geometric. When one is missing or wrong, it registers immediately.

**Graffiti** accumulates visually across the acts. By Act 3, the walls are covered. By Act 4, there's almost no bare stone visible. The density of markings is a direct visual meter of how long people have been trapped here.

**No UI except the distance panel.** Everything else — health, progress, act markers — does not exist in a heads-up display. It exists in the world or it doesn't exist.

---

## 14. Out of Scope

The following are explicitly not part of this game's first version. They may be revisited in future iterations:

- Multiple distinct corridors or environments
- Any form of combat or direct threat
- Voice acting or narration
- Procedural anomaly generation (all anomalies are hand-authored)
- Mobile platform support
- Multiplayer or co-op
- Collectibles or achievements
- New Game+ or difficulty modifiers

The discipline of this list is as important as everything above it. The game is good if it executes its narrow premise with precision. Scope creep is the primary risk.

---

*GDD v0.1 — Subject to revision as production begins.*  
*All section names, working title, and anomaly specifics are provisional.*
