#import "/wiki/template.typ": *

#show: wiki-page.with(
  title: "Art Direction",
  subtitle: "Visual Style, Palette, and Procedural Generation",
  version: "1.0",
)

= Visual Identity

== Style Target

*High-contrast ink-wash / lithograph.* Dark, organic, slightly printed-looking. The visual language should feel like an old geological survey or a Victorian-era illustration of underground passages — technical but haunting.

== Core Principles

- The player sees only what the torch illuminates. The rest is dark.
- Warmth = safety. Cold = uncertainty.
- Shapes outside the torch beam are barely legible — the player can't trust peripheral vision.
- No UI clutter. The world IS the interface.


= Rendering

== Side-Scrolling 2D

Three parallax layers create depth without 3D assets:

#table(
  columns: (1fr, 2fr, 1.5fr),
  [Layer], [Content], [Visual Character],
  [Background],
  [Rough limestone, cracks, moisture stains],
  [Deep, barely visible, geological],

  [Midground],
  [Ossuaire walls, brick sections, objects],
  [Primary detail layer, where anomalies live],

  [Foreground],
  [Stone frame edges, partial ceiling],
  [Framing, partially obscures view],
)

== Procedural Textures

Base textures are generated procedurally, not hand-painted:

=== Stone Surfaces

Layered Perlin/Simplex noise:
- *Large scale:* geological features — broad cracks, surface undulation, moisture zones.
- *Fine scale:* grain texture — individual stone roughness.
- Multiple octaves blended for organic feel.

=== Brick & Mortar

Voronoi noise:
- Cell boundaries define mortar lines.
- Cell interiors have their own Perlin variation for individual brick character.
- Mortar lines slightly irregular — not a perfect grid.

=== Generation Strategy

- Generated at startup or first launch.
- Cached for consistency within a session.
- Seed-based for reproducibility if needed.

== Open-Source Assets

Elements that cannot be procedurally generated use open-source assets:
- Skulls and bones (ossuaire elements)
- Backpack
- Candle
- Rope
- Work lamp
- Fluorescent lamp

These should be processed to match the ink-wash/lithograph visual style — high contrast, limited tonal range, organic edges.


= The Torch

The torch is the primary visual mechanic.

== Behavior

- Follows mouse / right stick in full 2D (up, down, left, right).
- Illuminates a warm, imperfect cone of light.
- Soft falloff at edges — not a hard circle, but a gradual fade into darkness.
- Battery is unlimited. The torch is a tool of *focus*, not a resource.

== Light Characteristics

- *Shape:* roughly conical, slightly irregular at edges.
- *Color:* warm ochre, amber. Should feel like firelight or an old incandescent bulb.
- *Falloff:* soft gaussian or cosine falloff. The transition from lit to dark should feel organic.
- *No hard shadows* from the torch itself — the light is diffuse enough to not cast crisp edges.

== Player Silhouette Effect

The torch projects light *forward/outward from the player*. This keeps the player character in *permanent silhouette* — backlit against their own light. The player sees their own shape as a dark cutout against the illuminated corridor ahead.

This is both an aesthetic choice and a mechanical one: the player's attention is always directed forward, into the light, searching for anomalies.


= The Player Character

== Silhouette Only

- Never detailed, never identifiable.
- A dark human shape against the torchlight.
- Approximately *1/6 of screen height*.
- No visible gender, race, age, or features. Just a person.

== Inclusivity by Design

The silhouette approach is deliberate: any player can project themselves onto this figure. The character is defined by their actions (walking, aiming the torch, turning back) rather than their appearance.


= Color Palette

== Primary Palette

#table(
  columns: (1.2fr, 1.5fr, 2fr),
  [Role], [Color], [Usage],
  [Torch light], [Warm ochre, amber], [Illuminated areas, safety],
  [Ambient dark], [Cold grey-blue, dark brown-grey], [Unlit areas, uncertainty],
  [Deep black], [Near-black with slight warmth], [Deepest shadows, background],
  [Highlight], [Pale warm yellow], [Direct torch center, brightest point],
)

== Emotional Mapping

- *Warm tones* = torch reach = known, safe, observed.
- *Cold tones* = beyond reach = unknown, uncertain, potentially wrong.
- The contrast between warm and cold is the visual language of the entire game.

== Colorblind Considerations

The warm-vs-cold distinction is primarily a *luminance* contrast as well as a *hue* contrast. This means the core readability should survive most forms of color blindness. Specific palettes for protanopia, deuteranopia, and tritanopia should be tested and offered as options.


= UI Philosophy

== No HUD

- No health bar, no minimap, no act markers, no floating text.
- The only persistent UI elements exist in the lobby: distance panel and anomaly counter.
- The pause overlay (Escape / Start) is the only non-diegetic UI element.

== Lobby UI

- *Distance panel:* "EXIT — 60m" style. Clear, readable, integrated into the environment.
- *Anomaly counter:* "12 / 35" style. Discovered / total.
- *Collection menu:* accessible from the lobby, shows discovered anomalies with visuals and descriptions.

== Main Menu

Integrated into the first lobby of a session:
- Continue / New Run / Options / Quit.
- Presented as in-world elements or very subtle UI — not a traditional menu screen.


= The Corridor — Visual Reference

== Zones

The corridor is divided into three zones. Each has distinct visual character:

=== Zone A — First Third

Open, relatively spacious feel. Puddles on the floor catch and reflect torchlight. The red painted arrow is a strong visual anchor. The carved date "1786" provides a historical grounding.

=== Zone B — Middle Third

The densest zone visually. The ossuaire wall with its row of 7 skulls is the primary visual set-piece. The abandoned backpack adds human presence. The broken work lamp and hanging cable suggest recent human activity.

=== Zone C — Final Third

The fluorescent lamp provides a second, cold light source that competes with the torch. The Latin inscription "MEMENTO MORI" and the unlit candle are the main visual anchors. The coiled rope suggests preparation or escape.

== Curve

The corridor has a slight curve — the far end is never fully visible from the entrance. This creates natural occlusion: the player must walk forward to see what's ahead. The curve should be gentle enough that most of the corridor is visible, but sharp enough that the final few meters are hidden.
