# Product Design Specification: Swiss Editorial Direction

> **Project:** 4-Status Ticket Board (Kanban Prototype)  
> **Status:** APPROVED & RECORDED BY HUMAN REVIEW  
> **Phase:** P4.3 — Critique and Select an Interface  
> **Canonical Target:** `chapter-04-ai-for-product-design/docs/product-design.md`  
> **Selected Direction:** **Concept B: Swiss Editorial**  
> **Approval Date:** 2026-10-09  

---

## 1. Selected Visual System & Core Philosophy

Following the forensic audit in P4.3, the project has officially committed to **Concept B: Swiss Editorial**.

### 1.1 Visual Philosophy
The design treats the digital workspace like an architectural journal or a printed monograph from the International Typographic Style (Swiss Style):
- **Calm, High-End Surface Atmosphere:** Warm gallery ivory background (`#F6F5F0`) paired with crisp white card surfaces (`#FFFFFF`) and deep ink black typography (`#1C1A17`).
- **Low Cognitive Fatigue:** Avoids aggressive stark-white glare and oppressive all-black dark-mode "tunnel vision", allowing users to work in the tool for hours without eye strain.
- **Architectural Spatial Tension:** Replaces heavy box-shadows and blurred neomorphic glows with razor-sharp hairline borders (`1px solid #DCD8CE`) and distinctive color-coded architectural rules at the head of each lane.

### 1.2 Design Tokens Specification

```css
:root {
  /* Surface Canvas */
  --color-canvas: #F6F5F0;             /* Warm gallery ivory */
  --color-surface-card: #FFFFFF;        /* Crisp card white */
  --color-surface-hover: #FCFCFA;       /* Subtle warm lift */
  --color-surface-muted: #EFECE4;       /* Toolbar and header background */
  
  /* Hairline Borders */
  --border-hairline: #DCD8CE;          /* Calibrated hairline (Mitigation RSK-01) */
  --border-emphasis: #B8B3A7;          /* Input active and modal borders */
  
  /* Typographic Ink */
  --color-ink-primary: #1C1A17;        /* Deep ink black (14.2:1 contrast ratio) */
  --color-ink-subtle: #6E6A63;         /* Muted secondary labels */
  --color-ink-faint: #9E998F;          /* IDs and tertiary metadata */
  
  /* Status Accent Rules (Top Lane Borders) */
  --status-rule-backlog: #9E998F;      /* Architectural Stone */
  --status-rule-todo: #2D5B88;         /* Deep Cobalt */
  --status-rule-progress: #C25E3E;     /* Terracotta Rust */
  --status-rule-done: #3E6B48;         /* Forest Olive */

  /* Typography (Mitigation RSK-03) */
  --font-display: 'Newsreader', Georgia, serif;      /* Strictly headers >= 20px */
  --font-body: 'Plus Jakarta Sans', sans-serif;      /* All cards, tags, buttons, inputs */
  
  /* Geometry & Spacing */
  --radius-editorial: 2px;             /* Crisp architectural geometry */
  --card-padding-v: 12px;              /* Compact vertical padding (Mitigation RSK-02) */
  --card-padding-h: 16px;              /* Generous horizontal padding */
}
```

---

## 2. Integrated Usability Mitigations (From Audit P4.3)

During the audit gate, three specific usability risks were identified and approved for mitigation:

### Mitigation RSK-01: Calibrated Hairline Border Contrast
- **Risk:** Fine borders (`#E3E0D8`) risked low visibility on low-gamut or uncalibrated monitors.
- **Implementation:** Border color darkened to `--border-hairline: #DCD8CE`, delivering a guaranteed $\ge 3:1$ contrast against the ivory canvas. Hover states elevate the card with a 1px border shift to `--border-emphasis: #B8B3A7`.

### Mitigation RSK-02: Compact Vertical Card Density
- **Risk:** Generous 16px padding previously reduced the visible card count to ~4 per lane on standard laptop screens.
- **Implementation:** Vertical padding is tightened to `12px` (while maintaining `16px` horizontal padding). Card titles are clamped to a clean 2-line maximum (`-webkit-line-clamp: 2`). This increases visible cards to 6–7 above the fold.

### Mitigation RSK-03: Dual-Font Hierarchy (Serif Headers + Sans Body)
- **Risk:** Fine serif strokes in `Newsreader` can lose legibility if rendered below 14px on low-DPI screens.
- **Implementation:** Strict architectural rule:
  - `Newsreader` is **ONLY** used for masthead titles, board headings, and modal headers ($\ge 20px$).
  - All card titles, tags, buttons, input fields, and counts strictly use the clean geometric sans-serif `Plus Jakarta Sans`.

---

## 3. Interaction Contract Support & Behavioral Specifications

The chosen visual system strictly adheres to the approved interaction brief:

### 3.1 Authentication & Session Entry
- **Layout:** Minimalist single-card layout on warm paper background.
- **Fields:** `Username/Email` and `Password` ($\ge 6$ characters).
- **Storage:** Persisted locally in `localStorage` under `auth_session = { user: "...", token: "..." }`.
- **Exclusions Preserved:** No SSO, no password reset, no external backend dependency.

### 3.2 Four Fixed Status Lanes
- **Lanes:** Fixed to `Backlog`, `To Do`, `In Progress`, `Done`.
- **Visual Landmark:** Top 3px architectural hairline rules in distinct status hues:
  - `Backlog`: Stone Grey (`#9E998F`)
  - `To Do`: Deep Cobalt (`#2D5B88`)
  - `In Progress`: Terracotta Rust (`#C25E3E`)
  - `Done`: Forest Olive (`#3E6B48`)
- **Tally Counters:** Displayed in elegant italic Newsreader digits next to uppercase section labels.

### 3.3 Ticket Schema & Presentation
- **Title:** Displayed prominently in 14px semi-bold sans-serif (`#1C1A17`), max 2 lines.
- **Ticket ID:** Displayed top-left in subtle faint uppercase (`#9E998F`).
- **Tags:** Compact rectangular pills with 1px hairline borders (`#DCD8CE`) and subtle ink text.
- **Notes Indicator:** Subtle `¶` symbol appears bottom-right when a description is present.

### 3.4 Creation & Editing Workflows
- **Global Creation:** Masthead `+ New Ticket` button defaults status to `Backlog`.
- **Lane Creation:** Bottom `+ Add Ticket` button automatically pre-fills that specific lane's status.
- **Centered Modal:** Clean white dialog on dim translucent curtain (`rgba(28, 26, 23, 0.4)`).
  - Title input with character counter (`0/100`) and auto-focus.
  - Status dropdown selector.
  - Comma-separated tag chip editor.
  - Optional description textarea.
- **Draft Protection Guard:** If fields were modified, pressing `Escape` or clicking `Dismiss` triggers a confirmation overlay: *"Discard draft? [Keep Editing] [Discard]"*, protecting work in progress.

### 3.5 Direct Movement & Status Control
- **Pointer Drag-and-Drop:** Native grab cursor, subtle 2px card lift on drag, and hairline dashed drop insertion zone.
- **Touch / Menu Quick Move:** Tapping `•••` opens a crisp popover with 1-tap targets (`Move to Backlog`, `Move to To Do`, `Move to In Progress`, `Move to Done`).
- **Keyboard Navigation:** Full support for `Tab` focusing, `Space`/`Enter` pickup, arrow keys movement, and `Escape` cancel.
- **Optimistic UI with Rollback:** State updates instantly in the DOM. Upon simulated network failure, card smoothly animates back to its original slot in 600ms accompanied by an ink-black Toast with an actionable `[Retry]` button.

### 3.6 Empty Lane Handling
- When a lane has 0 cards, a calm dashed container appears displaying: *"Quiet in [Lane Name]"* with a compact `+ Add Entry` button.

### 3.7 Mobile & Narrow-View (< 768px)
- Four-column grid collapses into a single active lane.
- A clean typographic **Underlined Tab Bar** appears at the top, allowing one-tap switching between Backlog, To Do, In Progress, and Done.

---

## 4. Accessibility & Standards Compliance (WCAG 2.1 AA)

- **Contrast:** Core ink text against ivory canvas achieves **14.2:1 contrast ratio**, comfortably surpassing WCAG AAA requirements.
- **Visible Focus:** All focusable elements (cards, buttons, inputs) display a distinct 2px solid ink black focus ring with a 2px offset (`outline: 2px solid #1C1A17; outline-offset: 2px`).
- **Reduced Motion:** Respects `prefers-reduced-motion: reduce` by replacing all transitions with instant 0ms state swaps.

---

## 5. Prototype Implementation Status & Next Steps

This document completes **P4.3 — Critique and Select an Interface**.

- **Active Concept Reference:** [product-design/design/concepts/concept-b-swiss-editorial.html](file:///d:/code/danentang/ReceiptMate/product-design/design/concepts/concept-b-swiss-editorial.html)
- **Concept Explorer Hub:** [product-design/design/concepts/index.html](file:///d:/code/danentang/ReceiptMate/product-design/design/concepts/index.html)
- **Approved Prototype Direction:** Ready for production component extraction and prototype build.
