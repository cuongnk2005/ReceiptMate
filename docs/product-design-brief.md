# Product Design Brief: 4-Status Ticket Board

> **Project:** 4-Status Ticket Board (Kanban Prototype)  
> **Status:** APPROVED BY HUMAN REVIEW  
> **Phase:** P4.1 — Product Design Brief  
> **Canonical Path:** `chapter-04-ai-for-product-design/docs/product-design-brief.md`  
> **Author:** Primary Design Agent (`$brainstorm` + `$frontend-expert`)  
> **Version:** 1.0.0 (Interaction Contract Approved)

---

## 1. Executive Summary & The User Struggle

### 1.1 The User Struggle (Job-To-Be-Done)
Knowledge workers, individual contributors, and small teams struggle with bloated issue tracking tools (e.g., Jira, ClickUp) that introduce heavy cognitive friction:
- **Excessive Ceremony:** Too many required fields, nested dropdowns, and slow modal transitions interrupt flow.
- **Fragile Movement:** Drag-and-drop on mobile screens or via keyboards is often broken or non-existent, leaving users with clumsy workaround clicks.
- **Accidental Work Loss:** Closing a ticket modal inadvertently destroys partially written task descriptions or tag setups without warning.
- **Context Loss:** When lanes are empty or tickets disappear during status updates, users feel disoriented about whether the action succeeded or failed.

### 1.2 Core Experience Decisions
| Dimension | Decision | UX Rationale |
| :--- | :--- | :--- |
| **Creation Flow** | Single focused modal with sensible defaults | Minimizes time-to-card creation (< 3 seconds for title-only cards). |
| **Status Transition** | Direct drag + one-touch menu fallback | Unblocks individual velocity; immediate optimistic UI with error rollback. |
| **Mobile Layout** | Segmented Tab Switcher (Single Lane) | Eliminates horizontal scroll fatigue and accidental off-screen drags. |
| **Persistence Boundary** | Client memory / `localStorage` | Instant prototype feedback; zero backend server dependency. |

---

## 2. Session Entry & Authentication Contract (Prototype Boundary)

### 2.1 Scope & Boundary
To maintain a strict prototype boundary without external backend dependencies, session management operates entirely in client `localStorage`.

* **Entry Flow (Login / Register):**
  - Minimalist single-card layout.
  - Fields: `Username / Email` (required, text), `Password` (required, $\ge 6$ characters).
  - Mode Switch: Toggle between "Sign In" and "Create Account" without page reload.
  - Mock Session: On submit, generates a persistent local session token and redirects directly to the Board view.
  - Session Persistence: Stored in `localStorage` (`auth_session = { user: "...", token: "..." }`). Reloading the page maintains active session.
  - Sign Out: A dedicated button in the header clears the local token and returns to the entry screen.
* **Explicit Exclusions:**
  - ❌ No password reset flow or "Forgot password" links.
  - ❌ No SSO, OAuth, Google/GitHub social logins.
  - ❌ No email verification or two-factor authentication (2FA).

---

## 3. Ticket Contract & Data Schema

Each ticket is a self-contained unit of work governed by a strict schema:

```typescript
interface Ticket {
  id: string;               // Unique UUID or timestamp-derived string (e.g., "TCK-101")
  title: string;            // Required, trimmed, 1 - 100 characters
  description?: string;     // Optional, plain text / basic markdown, max 1000 characters
  status: TicketStatus;     // Exactly one of the 4 fixed statuses
  tags: string[];           // Array of tag labels (max 5 tags per ticket, max 20 chars each)
  createdAt: string;        // ISO-8601 UTC timestamp
  updatedAt: string;        // ISO-8601 UTC timestamp
}

type TicketStatus = "backlog" | "todo" | "in_progress" | "done";
```

### Field Behaviors
- **Title:** Primary scannable identifier on the card face. Ellipsis truncation after 2 lines (`line-clamp-2`).
- **Description:** Indicated on card face by a subtle icon indicator if present. Full text visible only in the detail/edit modal.
- **Tags:** Rendered as compact, color-coded pill badges. Overflows beyond 3 tags show a `+N` indicator.
- **Status:** Displayed contextually by the lane the card resides in; selectable via dropdown in modal view.

---

## 4. Four-Status Board Architecture

The board consists of exactly **four fixed lanes** representing the lifecycle of work:

```
┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐
│     BACKLOG     │      TO DO      │   IN PROGRESS   │      DONE       │
│   (Count: 3)    │   (Count: 1)    │   (Count: 2)    │   (Count: 5)    │
├─────────────────┼─────────────────┼─────────────────┼─────────────────┤
│ [Card 101]      │ [Card 104]      │ [Card 105]      │ [Card 107]      │
│ [Card 102]      │                 │ [Card 106]      │ [Card 108]      │
│ [Card 103]      │                 │                 │ [Card 109]      │
│                 │                 │                 │                 │
│ [+ Add Ticket]  │ [+ Add Ticket]  │ [+ Add Ticket]  │ [+ Add Ticket]  │
└─────────────────┴─────────────────┴─────────────────┴─────────────────┘
```

1. **Backlog:** Unprioritized items, raw ideas, deferred tasks.
2. **To Do:** Committed tasks ready for execution in the current iteration.
3. **In Progress:** Work actively underway (WIP visual cue).
4. **Done:** Completed work. Tickets in this column display subtle muted styling or checkmark badge.

### Board Header Controls
- **Board Title:** "Project Board"
- **Global "+ New Ticket" Button:** Primary CTA button positioned top-right.
- **Search / Filter Input:** Real-time text filtering across ticket titles and tags.
- **User Avatar / Sign Out:** Compact dropdown indicating current mock session.

---

## 5. Creation & Editing Workflows

### 5.1 Trigger Points & Status Fallback
- **Global Creation ("+ New Ticket" in Top Bar):**
  - Opens modal with `Status` defaulting to `Backlog` (Status Fallback Rule).
- **Lane Creation ("+ Add Ticket" at bottom of specific lane):**
  - Opens modal with `Status` pre-filled to that specific lane's status (e.g., clicking in "In Progress" defaults status to `In Progress`).
  - User can still manually change status via the modal's dropdown before saving.

### 5.2 Centered Create/Edit Modal Interaction
- **Placement:** Centered overlay with a dimmed backdrop (`rgba(0, 0, 0, 0.5)`).
- **Focus Management:** Focus automatically moves to the `Title` input on modal open.
- **Form Controls:**
  - `Title`: Auto-focused input, character counter (`0/100`).
  - `Status`: 4-option native select or custom segmented picker.
  - `Tags`: Tag input with comma/Enter chip creation and remove `(x)` button.
  - `Description`: Multi-line textarea with auto-grow up to 6 lines.
- **Actions:**
  - `Save / Create`: Primary CTA.
  - `Cancel`: Secondary text button.
  - `Delete`: Destructive button (visible in Edit mode only, triggers confirmation).
- **Dismissal:**
  - Clicking backdrop or pressing `Escape` triggers exit.
  - **Draft Protection Guard:** If fields were modified, a prompt asks: *"Discard unsaved changes? [Keep Editing] [Discard]"*.

---

## 6. Direct Movement & Status Control Contract

To satisfy both mouse, touch, and accessibility-first users, ticket movement provides **three parallel interaction models**:

```
┌────────────────────────────────────────────────────────────────────────┐
│                      TICKET MOVEMENT CHANNELS                          │
├───────────────────┬────────────────────────────┬───────────────────────┤
│ 1. Pointer (Drag) │ Direct drag-and-drop       │ Drop indicators,      │
│                   │ with grab cursor           │ ghost cards, preview  │
├───────────────────┼────────────────────────────┼───────────────────────┤
│ 2. Touch (Mobile) │ Long-press drag OR         │ Quick Move Sheet with │
│                   │ tap "Move" quick action    │ one-tap lane targets  │
├───────────────────┼────────────────────────────┼───────────────────────┤
│ 3. Keyboard (A11y)│ Space/Enter to pickup card │ Live ARIA speech,     │
│                   │ Arrow keys to reposition   │ zero mouse dependency │
└───────────────────┴────────────────────────────┴───────────────────────┘
```

### 6.1 Direct Pointer Drag & Drop
- **Grab Threshold:** 4px drag delta prevents accidental clicks when attempting to open edit modal.
- **Visual Feedback:** Card tilts slightly (3 deg), gains an elevated drop shadow (`box-shadow: 0 12px 24px rgba(0,0,0,0.15)`), and original lane slot turns into a dashed placeholder slot.
- **Drop Targets:** Hovering over any lane expands a drop insertion line.

### 6.2 Touch Ergonomics
- Direct touch dragging requires a **250ms long-press** with haptic feedback to prevent conflicts with vertical page scrolling.
- **Quick Action Alternative:** Tapping the card's `···` (More) menu exposes:
  `[Move to Backlog] | [Move to To Do] | [Move to In Progress] | [Move to Done]`.

### 6.3 Keyboard Navigation Contract
1. User tabs to a ticket card (`tabindex="0"`, receives high-contrast focus ring).
2. Pressing `Space` or `Enter` "picks up" the card. System announces: *"Card picked up. Current lane: To Do, position 1 of 3"*.
3. Pressing `ArrowLeft` / `ArrowRight` moves the card between lanes.
4. Pressing `ArrowUp` / `ArrowDown` adjusts vertical position within the current lane.
5. Pressing `Space` or `Enter` drops the card.
6. Pressing `Escape` cancels movement and restores original position.

### 6.4 Optimistic Movement with Rollback & Retry
- Card moves immediately in the UI (Optimistic UI).
- An asynchronous state sync is executed.
- If an unexpected error occurs:
  1. Card animates smoothly back to original position (Rollback).
  2. A toast notification appears: *"Failed to move ticket. [Retry]"* (5-second duration).

---

## 7. Comprehensive Frontend State Matrix (`$frontend-expert`)

| State Type | Trigger / Condition | Visual & Observable Behavior | Interactive Capabilities |
| :--- | :--- | :--- | :--- |
| **Loading** | Initial session/board load or filter execution. | 4 columns render skeleton cards (pulsing gray rects, 3 per lane). Header buttons are inactive. | Non-blocking board layout; user can still switch tabs. |
| **Empty Lane** | A lane contains 0 tickets. | Dashed border outline container; centered muted illustration + text: *"No tickets in [Lane Name]"*; prominent `[+ Add Ticket]` button. | Clicking the empty zone opens create modal pre-filled with that lane's status. Accepts dropped cards. |
| **Global Empty** | Fresh board with 0 tickets across all 4 lanes. | Central empty hero graphic: *"Your board is clear"*; Primary button `[Create First Ticket]`. | High-emphasis onboarding guidance. |
| **Error State** | Form validation fails or storage quota exceeded. | Affected input outlines in red (`#D32F2F`); helper error text appears beneath input. Toast displays storage error if saving fails. | Form data remains 100% intact; focus shifts to invalid field. |
| **Disabled** | Submitting ticket form or title is empty. | Save button opacity drops to 50%; cursor becomes `not-allowed`; spinner replaces icon. | Prevents double submission. |
| **Focus State** | Keyboard `Tab` navigation. | 2px solid primary accent ring with 2px offset (`outline: 2px solid #2C4570; outline-offset: 2px`). | Visible across all interactive elements (cards, buttons, tags). |
| **Touch State** | Finger touch down on mobile. | Target element scales down slightly (`scale(0.98)`); touch targets $\ge 44 \times 44$ px. | Distinguishes tap from scroll gesture. |
| **Narrow-View** | Screen width $< 768px$ (Mobile). | Lanes transform into a top **Segmented Tab Bar** (`[Backlog (3)] [To Do (1)] [In Prog (2)] [Done (5)]`). Only 1 active lane visible at a time. | Swipe left/right between lanes; global FAB replaces header CTA. |
| **Reduced-Motion**| User OS has `prefers-reduced-motion: reduce`. | All transform/tilt animations, skeleton wave pulses, and modal zoom transitions are replaced with instant cut transitions (`duration: 0ms`). | Complies with vestibular motion sensitivity guidelines. |

---

## 8. Accessibility & Usability Contract (WCAG 2.1 AA)

- **Contrast Ratios:** All text elements (titles, descriptions, tags, lane headers) achieve at least **4.5:1** contrast against their background. Large titles achieve $\ge 3:1$.
- **ARIA Landmark & Roles:**
  - Board container: `<main role="main">`
  - Columns: `<section role="region" aria-label="[Lane Name] lane, [N] tickets">`
  - Cards: `<article role="listitem" tabindex="0" aria-roledescription="draggable ticket">`
  - Status updates: `<div role="status" aria-live="polite" class="sr-only">` announces moves.
- **Modal Focus Trap:** Focus is strictly locked within the modal while open. Tabbing past the last action wraps to the close button. Background elements are marked `aria-hidden="true"`.

---

## 9. Responsive Breakdown

```
┌────────────────────────────────────────────────────────────────────────┐
│                         RESPONSIVE BREAKPOINTS                         │
├────────────────────┬───────────────────────────────────────────────────┤
│ Desktop (≥ 1024px) │ 4 equal columns side-by-side (min-width: 260px)   │
│                    │ Full drag-and-drop across horizontal canvas       │
├────────────────────┼───────────────────────────────────────────────────┤
│ Tablet (768-1023px)│ 2x2 grid or horizontally swipeable lane rail      │
│                    │ Header remains compact single line                │
├────────────────────┼───────────────────────────────────────────────────┤
│ Mobile (< 768px)   │ Segmented Lane Switcher Tab Bar at top            │
│                    │ Single lane displayed vertically at a time        │
│                    │ Floating Action Button (+) for instant creation   │
│                    │ Bottom Sheet replaces centered modal              │
└────────────────────┴───────────────────────────────────────────────────┘
```

---

## 10. Explicit Non-Goals & Scope Exclusions

To keep the prototype focused and unburdened by enterprise bloat, the following are strictly excluded:
1. ❌ **No Remote Database / Cloud Sync:** All states reside in client memory / `localStorage`.
2. ❌ **No Multi-Board Switcher / Workspaces:** Exactly one primary project board is supported.
3. ❌ **No Password Recovery, SSO, or Social Logins:** Authentication is a mock prototype boundary.
4. ❌ **No Analytics Dashboards, Burn-down Charts, or Reports:** Board is purely operational.
5. ❌ **No Custom Column Workflows:** Lanes are fixed to the 4 canonical statuses.
6. ❌ **No Sub-tasks or Checklist Trees:** Tickets remain single-level atomic work units.

---

## 11. Sign-off & Next Steps

This document has passed the **Human Approval Gate** and serves as the binding behavioral contract for:
1. **P4.2:** Visual exploration & design token extraction.
2. **P4.3:** Interactive prototype implementation.
