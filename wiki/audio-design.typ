#import "/wiki/template.typ": *

#show: wiki-page.with(
  title: "Audio Design",
  subtitle: "Soundscape, Spatial Audio, and Anomalies",
  version: "1.0",
)

= Audio Philosophy

== Core Principle

Everything the player hears should be explainable by the physical space — until an audio anomaly breaks that rule.

There is no composed music. No score. No soundtrack. The catacombs are the instrument. The player learns the canonical soundscape through repetition, and anomalies exploit that learned familiarity.

== Dual Role of Audio

+ *Establish the canonical soundscape* — the "normal" that anomalies deviate from.
+ *Support the emotional arc* — subtle shifts in the mix that make the corridor feel increasingly unreliable.


= Procedural Soundscape

Inspired by myNoise — layered, continuous, generated from parameters rather than fixed audio files.

== Base Layers

#table(
  columns: (1fr, 1.5fr, 1.5fr),
  [Layer], [Character], [Spatial Position],
  [Water drips], [Irregular, persistent], [Far end of corridor],
  [Fluorescent hum], [Low, constant], [Zone C only],
  [Air current], [One cold breath per traversal, random timing], [Moves through corridor],
)

== Event Sounds

#table(
  columns: (1fr, 1.5fr, 1.5fr),
  [Event], [Character], [Frequency],
  [Structure creak], [Distant, metallic], [Every \~30 seconds],
  [Air breath], [Cold, brief], [Once per traversal, random],
)

== Player Sounds

#table(
  columns: (1fr, 2.5fr),
  [Sound], [Character],
  [Footsteps], [Wet stone echo, slightly delayed. Changes with surface texture.],
  [Stop/start], [Brief silence, then echo tail fades.],
)

== Parameter-Driven Generation

Each sound layer is defined by parameters that can be tuned:
- Frequency / interval range
- Volume range
- Pitch variation range
- Spatial position (fixed or moving)
- Reverb/echo characteristics

These parameters are the foundation for both the canonical soundscape and the subtle shifts across the run.


= Soundscape Arc

The base soundscape parameters shift subtly as the player progresses through passes in a run. The player should never consciously notice the shift — it operates below the threshold of awareness.

== Early Passes

Neutral, realistic catacomb ambiance. Drips, hum, echo. The player should feel like they're actually in a catacomb, not a horror game. Everything is explainable, everything is grounded.

== Mid Passes

The same sounds, but the mix shifts:
- Frequencies become slightly wrong (hum shifts pitch imperceptibly).
- Silences between drips feel louder — the absence of sound becomes present.
- Echo characteristics change subtly (slightly longer decay, slightly different timbre).

== Late Passes

The soundscape becomes unreliable. Audio anomalies are maximally effective here because the player has fully internalized what this place *should* sound like. Any deviation from that is deeply wrong.

== Final Corridor

Near silence. The dripping has stopped. The hum is gone. Footsteps echo more than they should, as if the space has gotten larger. The only sound is the player's own movement in a space that no longer responds normally.


= Open-Source VFX

One-shot sounds that cannot be procedurally generated are sourced from open-source libraries:

- Footstep impacts (multiple surfaces: wet stone, dry stone, puddle)
- Water drip impacts
- Metal creaks and groans
- Electrical hum and buzz
- Cable movement
- Rope sounds

These should be processed to match the acoustic character of an underground stone space: reverberant, slightly muffled high frequencies, prominent low-mid resonance.


= Spatial Audio

== Standard Mode

All sounds have spatial position:
- *Left/right panning* based on source location relative to player.
- *Distance attenuation* based on how far the source is from the player.
- *Reverb* characteristics reflect corridor geometry (narrow, stone, low ceiling).

Footstep echo behavior should feel physically correct — the echo returns from walls at a rate consistent with the corridor width.

== Blind Mode — Spatial Navigation

#callout(title: "Accessibility — Core System")[
  Spatial audio is the *only* navigation system in blind mode. It must be robust, learnable, and reliable.
]

=== Wall Proximity

A continuous sound cue that changes based on distance to the nearest wall:
- *Far from wall:* quiet or absent.
- *Near wall:* increases in intensity.
- *At wall:* distinct "close" sound.

This gives the player a sonar-like sense of the corridor's width and their position within it.

=== Floor Texture

Footstep sound changes based on what the player is walking on:
- *Dry stone:* sharp, crisp impact.
- *Wet stone:* slight splash, softer impact.
- *Puddle:* distinct water sound.

This provides spatial information about where the player is in the corridor (certain surfaces are in specific locations).

=== Lobby Beacon

A continuous low hum that is always spatially locatable — the player can always find the lobby by following this sound. It serves as the orientation anchor, equivalent to the distance panel in visual mode.

=== Navigation Summary

#table(
  columns: (1.2fr, 2.5fr),
  [Cue], [Information Provided],
  [Wall proximity], [Position within corridor width],
  [Floor texture], [Position along corridor length],
  [Lobby beacon], [Direction to lobby (orientation anchor)],
  [Footstep echo], [Corridor geometry — open vs. narrow],
)


= Audio Anomalies

Audio anomalies are deviations from the canonical soundscape. They are the *only* anomalies available in blind mode, and they supplement visual anomalies in standard mode.

== Design Principle

An audio anomaly must be detectable by a player who has internalized the canonical soundscape. It should not require superhuman hearing — just *attention* and *memory*.

== Catalogue

#table(
  columns: (3fr, 0.8fr, 0.8fr),
  [Anomaly], [Difficulty], [Channel],
  [Complete silence where dripping water should be], [#tag("tier 1", color: rgb("#60a060"))], [#tag("audio")],
  [Footsteps behind the player that stop when they stop], [#tag("tier 2", color: rgb("#d4a048"))], [#tag("audio")],
  [Echo returns slightly too late], [#tag("tier 2", color: rgb("#d4a048"))], [#tag("audio")],
  [Indistinct distant voice where there was none], [#tag("tier 2", color: rgb("#d4a048"))], [#tag("audio")],
  [The distant voice says something recognizable], [#tag("tier 3", color: rgb("#c04040"))], [#tag("audio")],
  [No sound at all — even footsteps are silent], [#tag("tier 3", color: rgb("#c04040"))], [#tag("audio")],
)

== Pool Balance for Blind Mode

#callout(title: "Design Constraint")[
  The audio anomaly pool must contain enough anomalies at every difficulty tier to fill a complete run. A blind mode player must never encounter a pass where no valid anomaly could be selected.
]

Current pool: 6 audio-only anomalies (2× Tier 1, 3× Tier 2, 2× Tier 3). This needs expansion — particularly at Tier 1 (obvious) to ensure the early game has variety. Additional audio anomalies to be designed during development.


= Technical Implementation Notes

== Audio Engine

The procedural soundscape requires an audio engine that supports:
- Multiple simultaneous sound sources with independent parameters.
- Real-time parameter modification (volume, pitch, spatial position).
- Spatial audio (at minimum stereo panning, ideally HRTF for headphone users).
- Low-latency playback for footsteps and interactive sounds.

== Bevy Audio

Bevy's built-in audio is basic. Likely candidates for the audio backend:
- `bevy_kira_audio` — feature-rich, good for layered sound design.
- `bevy_oddio` — spatial audio support, procedural generation friendly.
- Custom integration if needed for the myNoise-style procedural approach.

The choice should be made during the audio implementation phase (Priority 5 in the development plan), based on which library best supports the spatial audio and procedural generation requirements.
