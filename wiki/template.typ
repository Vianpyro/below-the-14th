// template.typ — Shared template for Below the 14th wiki
// Catacomb-themed: warm ochre accents on dark parchment tones

#let colors = (
  bg: rgb("#1a1714"),
  text: rgb("#e8dcc8"),
  heading: rgb("#d4a048"),
  accent: rgb("#c07830"),
  muted: rgb("#8a7e6c"),
  divider: rgb("#3d362c"),
  table-header: rgb("#2a2420"),
  table-row-alt: rgb("#211e1a"),
  tag-bg: rgb("#2a2420"),
  tag-text: rgb("#d4a048"),
  link: rgb("#c09050"),
  code-bg: rgb("#2a2420"),
)

#let wiki-page(
  title: "",
  subtitle: "",
  version: "0.1",
  body,
) = {
  set document(title: title, author: "Below the 14th")
  
  set page(
    fill: colors.bg,
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm),
    header: context {
      if counter(page).get().first() > 1 [
        #set text(font: "DejaVu Sans", size: 8pt, fill: colors.muted)
        #smallcaps[Below the 14th — #title]
        #h(1fr)
        #counter(page).display()
        #v(4pt)
        #line(length: 100%, stroke: 0.5pt + colors.divider)
      ]
    },
  )
  
  set text(font: "DejaVu Sans", size: 10pt, fill: colors.text, lang: "en")
  
  set heading(numbering: "1.1.")
  
  show heading.where(level: 1): it => {
    v(1.5em)
    block[
      #set text(font: "DejaVu Sans", size: 18pt, fill: colors.heading, weight: "bold")
      #it.body
      #v(4pt)
      #line(length: 100%, stroke: 1pt + colors.accent)
    ]
    v(0.8em)
  }
  
  show heading.where(level: 2): it => {
    v(1.2em)
    block[
      #set text(font: "DejaVu Sans", size: 13pt, fill: colors.heading, weight: "bold")
      #it.body
    ]
    v(0.5em)
  }
  
  show heading.where(level: 3): it => {
    v(1em)
    block[
      #set text(font: "DejaVu Sans", size: 11pt, fill: colors.accent, weight: "bold")
      #it.body
    ]
    v(0.4em)
  }
  
  // Links
  show link: it => {
    set text(fill: colors.link)
    underline(it)
  }
  
  // Code blocks
  show raw.where(block: true): it => {
    block(
      fill: colors.code-bg,
      inset: 12pt,
      radius: 4pt,
      width: 100%,
      stroke: 0.5pt + colors.divider,
    )[
      #set text(font: "DejaVu Sans Mono", size: 9pt, fill: colors.text)
      #it
    ]
  }
  
  // Inline code
  show raw.where(block: false): it => {
    box(
      fill: colors.code-bg,
      inset: (x: 4pt, y: 2pt),
      radius: 2pt,
    )[
      #set text(font: "DejaVu Sans Mono", size: 9pt, fill: colors.accent)
      #it
    ]
  }
  
  // Tables
  set table(
    stroke: 0.5pt + colors.divider,
    inset: 8pt,
    fill: (_, y) => if y == 0 { colors.table-header } else if calc.odd(y) { colors.table-row-alt } else { colors.bg },
  )
  show table.cell.where(y: 0): set text(fill: colors.heading, weight: "bold", size: 9pt)
  show table.cell: set text(size: 9pt)
  
  // Emphasis
  show emph: set text(fill: colors.accent)
  
  // Strong
  show strong: set text(fill: colors.heading)
  
  // --- Title page ---
  
  v(4cm)
  
  align(center)[
    #block[
      #set text(font: "DejaVu Sans", size: 32pt, fill: colors.heading, weight: "bold")
      #smallcaps(title)
    ]
    #v(8pt)
    #if subtitle != "" [
      #set text(font: "DejaVu Sans", size: 14pt, fill: colors.muted)
      #subtitle
    ]
    #v(1.5cm)
    #line(length: 40%, stroke: 1pt + colors.accent)
    #v(1cm)
    #set text(font: "DejaVu Sans", size: 10pt, fill: colors.muted)
    _Below the 14th_ — Project Wiki \
    Version #version \
    #datetime.today().display("[month repr:long] [day], [year]")
  ]
  
  pagebreak()
  
  // --- Table of contents ---
  
  block[
    #set text(fill: colors.text)
    #show outline.entry: it => {
      set text(fill: colors.text)
      it
    }
    #outline(indent: 1.5em, depth: 3)
  ]
  
  pagebreak()
  
  // --- Body ---
  body
}

// Utility: tag badge (for anomaly tags, difficulty tiers, etc.)
#let tag(label, color: colors.tag-text) = {
  box(
    fill: colors.tag-bg,
    inset: (x: 6pt, y: 3pt),
    radius: 3pt,
    stroke: 0.5pt + color,
  )[
    #set text(size: 8pt, fill: color, weight: "bold")
    #upper(label)
  ]
}

// Utility: callout box
#let callout(title: "", icon: "⚠", body) = {
  block(
    fill: colors.table-header,
    inset: 14pt,
    radius: 4pt,
    width: 100%,
    stroke: (left: 3pt + colors.accent),
  )[
    #if title != "" [
      #set text(fill: colors.heading, weight: "bold", size: 10pt)
      #icon #title
      #v(4pt)
    ]
    #set text(size: 9.5pt)
    #body
  ]
}

// Utility: design parameter table row helper
#let param(name, default, notes) = (
  raw(name), default, notes,
)
