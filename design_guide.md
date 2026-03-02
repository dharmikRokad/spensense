# Expense Tracker Design Guidelines

> The design system for the SpendWise expense tracker wireframe. These guidelines ensure every screen feels cohesive, trustworthy, and distinctly financial — not a generic to-do app with a dollar sign slapped on it.

---

## 1. Design Philosophy

**Tone:** Clean light-mode clarity — crisp, confident, and data-forward. Money is a serious topic. The UI should feel like a well-designed banking app: precise, honest, and reassuring. Not cold or bureaucratic — but never playful or distracting.

**Core principle:** Every screen exists to give the user a clearer picture of their financial reality. Information density is a feature, not a bug — but it must be organized with ruthless hierarchy. The user should always know their current balance, their biggest drain, and their progress toward a goal within 3 seconds of opening the app.

**What makes it unforgettable:** A pure white surface with sharp ink-black typography, a single emerald-green accent that signals financial health, and red as a strictly semantic color — used only for overspending. Data feels readable and calm, like a well-formatted spreadsheet elevated into a beautiful product.

**Light vs. Dark:** This app is **light-mode first**. Financial data is scanned quickly — light mode offers better legibility for numbers, tables, and charts at a glance. A dark mode variant can be offered as a setting but is not the default.

---

## 2. Color Palette

All colors are defined as constants and applied consistently across every screen.

| Token | Hex | Usage |
|---|---|---|
| `bg` | `#F7F8FA` | App background — off-white, never pure white |
| `surface` | `#FFFFFF` | Cards, nav bars, modals, input fields |
| `surface2` | `#F0F2F5` | Secondary cards, chip backgrounds, table row alternates |
| `border` | `#E4E7ED` | All dividers, card outlines, input borders |
| `accent` | `#1DB954` | Income, positive balance, savings goals, primary CTAs |
| `accentSoft` | `#E8F8EE` | Accent tinted backgrounds — success cards, income rows |
| `red` | `#EF4444` | Overspending, negative balance, budget exceeded alerts |
| `redSoft` | `#FEF2F2` | Red tinted backgrounds — over-budget cards, expense rows |
| `blue` | `#3B82F6` | Transfers, neutral transactions, informational states |
| `blueSoft` | `#EFF6FF` | Blue tinted backgrounds |
| `amber` | `#F59E0B` | Budget warnings (near limit), pending transactions |
| `amberSoft` | `#FFFBEB` | Amber tinted backgrounds |
| `text` | `#111827` | All primary body text — near-black, not pure black |
| `textSub` | `#6B7280` | Secondary labels, timestamps, helper text |
| `dim` | `#9CA3AF` | Inactive elements, placeholders, disabled states |

### Color Rules

- **Never use `#000000` pure black as text** — use `#111827` for warmth and reduced eye strain.
- **Green = income / positive. Red = expense / negative.** These are semantic — never swap them. Never use red decoratively.
- **Amber is a warning only** — budget approaching the limit (e.g. 80% spent). Not for branding.
- **Blue is for neutral/transfers** — money moving between accounts, not categorized as income or expense.
- **Backgrounds use `#F7F8FA`**, not white. Pure white is reserved for card surfaces only — this creates natural elevation without shadows.
- **Tinted soft backgrounds** (`accentSoft`, `redSoft`, etc.) are used inside cards to color-code transaction rows without full color blocks.
- **No gradients** — expense trackers need precision, not atmosphere. All surfaces are flat fills.

---

## 3. Typography

**Font family:** `Plus Jakarta Sans` (Google Fonts)

Plus Jakarta Sans was chosen for its financial credibility — it has the precision of a geometric sans with slightly humanist letterforms that keep it approachable. Numerals are especially clean and tabular, which is critical for an app full of money amounts.

| Role | Weight | Size | Usage |
|---|---|---|---|
| Balance hero / large amount | 800 | 32–40px | Total balance, monthly spend totals |
| Screen title | 700 | 18–20px | Page headings |
| Section heading | 600 | 14–15px | Card titles, group labels, category names |
| Amount (transaction) | 600 | 14–15px | Individual transaction amounts — always right-aligned |
| Body | 400 | 13–14px | Descriptions, notes, category names |
| Label / caption | 400 | 11–12px | Timestamps, tags, sub-labels |

### Typography Rules

- **Tabular numerals:** Use `font-variant-numeric: tabular-nums` on all money amounts so columns align perfectly. This is non-negotiable.
- **Right-align all amounts** in lists and tables — left-aligned money figures are visually chaotic and hard to compare.
- **Currency symbol** (`₹`, `$`, `€`) is always rendered at 70% the size of the amount — slightly smaller to keep the number as the focal point.
- **Negative amounts** (expenses) use `red` color + a minus sign prefix. **Positive amounts** (income) use `accent` green + a plus sign prefix.
- **Letter-spacing:** `letter-spacing: -0.5px` on large balance figures (32px+). No letter spacing on body copy.
- **Never italicize** UI text — this is a financial app, not a personal journal.
- **Font weight is the hierarchy** — use 800 for the single most important number on a screen, 600 for secondary data, 400 for everything else.

---

## 4. Spacing & Layout

### Grid & Padding
- **Screen horizontal padding:** `20px` on all sides — consistent across every screen.
- **Card internal padding:** `16px` all sides.
- **Stack gap between cards/sections:** `12px` default.
- **Gap between items in a list:** `0px` — list items use internal padding (`14px` vertical) with a `1px border-bottom` divider, not gaps.
- **Button padding:** `14px` vertical, `20px` horizontal. Full-width for primary actions, auto-width for secondary.

### Component Sizing
| Element | Value |
|---|---|
| Phone shell width | 340px |
| Phone shell height | 680px |
| Border radius — cards | 14px |
| Border radius — buttons | 12px |
| Border radius — chips/tags | 20px (pill shape) |
| Border radius — icon containers | 10px (rounded square, not circle) |
| Icon containers | 38×38px |
| Category icon size | 20px |
| Transaction row height | ~56px |

### Layout Rules
- **No horizontal scrolling** — every screen is a single vertical scroll.
- **Bottom nav is always 4 tabs** — Home, Transactions, Budgets, Profile. 4 tabs keeps it uncluttered.
- **Cards never nest inside cards** — maximum one level of surface elevation.
- **Money amounts are always right-aligned** in rows. Merchant names and categories are left-aligned. This creates a clean two-column visual in every list.
- **FAB (Floating Action Button)** is the one exception to "no floating elements" — a single `+` Add Transaction button floats at bottom-right. It uses `accent` green background.
- **Section headers** in transaction lists use full-width date labels (`Today`, `Yesterday`, `March 1`) with `textSub` color and `surface2` background — they are not cards, just sticky dividers.

---

## 5. Component Design

### Buttons

Three variants — consistent border-radius of 12px:

| Variant | Background | Text Color | Usage |
|---|---|---|---|
| `primary` | `#1DB954` (accent) | `#FFFFFF` | Main CTA — Add transaction, Save budget, Confirm |
| `danger` | `#EF4444` (red) | `#FFFFFF` | Destructive actions — Delete transaction, Clear data |
| `ghost` | transparent | `#6B7280` (textSub) | Secondary actions — Cancel, Skip, Edit later |

- Hover / press state: `opacity: 0.88` — no scale transforms.
- Never stack two filled buttons — always pair primary + ghost.
- The FAB is always 52×52px circle, `accent` background, white `+` icon at 24px.

### Cards

Standard card:
```
background: #FFFFFF (surface)
border: 1px solid #E4E7ED (border)
border-radius: 14px
padding: 16px
box-shadow: 0 1px 4px rgba(0,0,0,0.06)
```

Colored card variants:
- **Income / positive card:** `background: #E8F8EE (accentSoft)`, `border: 1px solid #1DB954 + 30% opacity`.
- **Over-budget / alert card:** `background: #FEF2F2 (redSoft)`, `border: 1px solid #EF4444 + 30% opacity`.
- **Warning card (near limit):** `background: #FFFBEB (amberSoft)`, `border: 1px solid #F59E0B + 30% opacity`.
- **Summary / balance card:** flat white with a subtle `box-shadow: 0 2px 12px rgba(0,0,0,0.08)` — the most elevated element on the dashboard.

### Transaction List Rows

Each row is the most repeated component in the app. Get this right:

```
height: ~56px
padding: 14px 20px
border-bottom: 1px solid #E4E7ED
background: #FFFFFF
```

Layout inside each row:
```
[Category Icon 38×38]  [Merchant Name (600, 14px)]     [Amount (600, right-aligned)]
                        [Category Tag + Date (11px)]    [+/- prefix, colored]
```

- Category icon container uses a **rounded square (10px radius)**, not a circle. Each category has its own background color (food = orange tint, transport = blue tint, etc.).
- Amounts are right-aligned, colored green (income) or red (expense).
- Swipe-to-delete reveals a red delete zone — not a button on the row itself.

### Category Chips / Tags

```
background: category tint color (soft)
color: category dark color
border-radius: 20px (pill)
padding: 3px 10px
font-size: 11px
font-weight: 600
```

Category color map (consistent across all screens):
| Category | Icon | Background | Text |
|---|---|---|---|
| Food & Dining | 🍜 | `#FFF3E0` | `#E65100` |
| Transport | 🚗 | `#E3F2FD` | `#1565C0` |
| Shopping | 🛍️ | `#FCE4EC` | `#C62828` |
| Entertainment | 🎬 | `#EDE7F6` | `#4527A0` |
| Health | 💊 | `#E8F5E9` | `#2E7D32` |
| Bills & Utilities | ⚡ | `#FFF8E1` | `#F57F17` |
| Income | 💰 | `#E8F8EE` | `#1A7A3F` |
| Transfer | 🔄 | `#EFF6FF` | `#1D4ED8` |

### Budget Progress Bars

```
height: 8px
border-radius: 8px
background (track): #E4E7ED (border)
```

Fill color changes based on consumption:
- `0–60%` → `accent` green
- `60–85%` → `amber`
- `85–100%` → `red`

Always show `₹spent of ₹limit` as a label row above the bar. Show percentage on the right.

### Input Fields

```
background: #FFFFFF
border: 1.5px solid #E4E7ED
border-radius: 10px
padding: 12px 14px
font-size: 15px
```

Focus state: `border: 1.5px solid #1DB954 (accent)` — green focus ring signals "go".

Amount input fields use a **large centered numpad-style layout** — full width, 32px font, currency symbol as a prefix label. Never a small inline field for entering money amounts.

### Bottom Navigation Bar

```
background: #FFFFFF (surface)
border-top: 1px solid #E4E7ED
padding: 10px 0 4px
```

Each tab: emoji/icon (20px) + label (10px, `dim` color). Active tab label uses `accent` green. Active tab icon gets a `accentSoft` background pill behind it.

---

## 6. Screen-Specific Design Patterns

### Dashboard (Home) Screen
- **Balance hero section** dominates the top — total balance at 36–40px, 800 weight, center or left aligned. This is the single most important number in the app.
- Month-to-date income vs. expense shown as two stat pills side by side beneath the balance — green pill for income, red pill for expenses.
- **Spending donut chart** (optional in wireframe, essential in production) sits in the summary card — shows category breakdown visually.
- Recent transactions show the last 3–5 rows directly on the dashboard — no need to go to the Transactions tab for a quick check.
- Budget health section: a horizontal scrollable row of budget cards showing the top 3 budgets with progress bars. Use amber/red coloring to instantly surface overspending.

### Add Transaction Screen
- **Full-screen modal or push screen** — this is the most-used action in the app. Give it space.
- Amount input is the first and most prominent field — large centered numpad layout. The number should fill the screen.
- Category selector: a horizontal scrollable chip row. Selected category chip gets the category's full tint color.
- Date defaults to today — tapping opens a minimal date picker.
- Notes/memo field is optional and visually de-emphasized (smaller, below the fold).
- Save button is fixed at the bottom — always visible regardless of keyboard state.

### Transactions List Screen
- Grouped by date with sticky section headers (`Today`, `Yesterday`, date strings).
- Filter/search bar at the top — allows filtering by category, date range, or amount.
- Each row follows the transaction row spec exactly (see Component Design above).
- Swipe left = delete (red zone). Swipe right = edit (blue zone).
- Running balance shown as a subtle sub-label on each day section header.

### Budget Screen
- Each budget is a card showing: category icon + name, amount spent vs. limit, progress bar, days remaining.
- Progress bar color changes (green → amber → red) based on consumption %.
- **Over-budget cards float to the top** of the list — red bordered, most urgent.
- "Add Budget" is a dashed-border card at the bottom of the list — consistent with common iOS pattern.
- Tap a budget card → drill-down to see all transactions under that category for the period.

### Analytics / Reports Screen
- **Bar chart** for monthly spend by category — grouped bars or stacked, rendered with fl_chart.
- **Line chart** for daily spending trend over the current month.
- Month selector at the top — left/right chevron to navigate months.
- Insight chips below charts: auto-generated observations in `surface2` pill chips (e.g. "Food up 23% vs last month").
- Top spending categories shown as a ranked list with category icon, name, amount, and % of total.

### Profile / Settings Screen
- Account summary at top: avatar, name, connected accounts.
- Currency and locale settings — prominent, since these affect every number in the app.
- Export data option (CSV / PDF) — give users control over their data.
- Notification preferences: budget alerts, weekly summary, bill reminders.
- No gamification, no streaks — this is a utility app. Settings are clean and functional.

---

## 7. Interaction Patterns

### Navigation Model
- **Onboarding** (Welcome → Currency Setup → Add First Account → Tutorial): linear 4-step flow. Progress indicator at top.
- **Main app**: bottom nav (4 tabs). The FAB `+` button is always accessible from any tab.
- **Add Transaction**: launches as a **bottom sheet modal** that slides up — preserves context of what the user was viewing.
- **Transaction detail**: pushes a new screen — full detail view with edit and delete options.
- **Budget drill-down**: pushes a new screen — filtered transaction list for that category.

### Empty States
- Empty transaction list: centered illustration (receipt icon) + "No transactions yet" + "Add your first transaction" CTA button.
- Empty budget screen: "No budgets set" + a nudge to create one with the potential monthly savings.
- Never show a blank screen. Always provide an action.

### Error Handling (UI Layer)
- Inline form validation: red border + red helper text directly below the invalid field. No full-screen errors.
- Insufficient data for chart: show a placeholder with "Add more transactions to see insights" — not an error, a prompt.
- Network error: top banner (not a modal) with retry. App should work fully offline for adding transactions.

### Gestures
- Swipe left on transaction row → delete (red background reveals).
- Swipe right on transaction row → quick edit (blue background reveals).
- Pull to refresh on transaction list → syncs with connected bank accounts (if feature enabled).
- Long-press on a transaction → multi-select mode for bulk delete or re-categorize.

---

## 8. Data Visualization Rules

Financial data visualization deserves its own section — charts are core, not decorative.

- **Bar charts:** Always start the Y-axis at 0. Never truncate. Misleading charts erode trust in a money app.
- **Colors in charts:** Use the category color map consistently. The donut chart slices should match the category chips in the transaction list.
- **No 3D charts.** Flat, clean 2D only.
- **Always show exact amounts** on hover/tap — tooltips are required, not optional.
- **Trend lines** use `accent` green if the trend is favorable (spending down), `red` if unfavorable (spending up vs. last period).
- **Empty chart state:** show the chart axes and a dashed placeholder line. Don't hide the chart UI just because there's no data yet.

---

## 9. Accessibility Considerations (Production Targets)

- **Contrast ratio:** All primary text (`#111827` on `#F7F8FA`) exceeds WCAG AAA (contrast ratio ~16:1). Red amounts on white cards must also be checked — `#EF4444` on `#FFFFFF` passes AA.
- **Touch targets:** All interactive elements minimum 44×44px — especially transaction rows and category chips.
- **Color-blind safe:** Never rely on green/red alone to communicate income vs. expense. Always pair with a `+`/`−` prefix symbol and the label "Income" / "Expense" where space allows.
- **Screen reader:** Amount fields need `aria-label="Amount in rupees"` or Flutter `Semantics(label: ...)`. Category icons need text alternatives.
- **Numeric input:** Use `keyboardType: TextInputType.number` and `inputFormatters` with currency masking — never let a user type a malformed amount.

---

## 10. What to Avoid

| ❌ Don't | ✅ Do instead |
|---|---|
| Dark background / dark mode by default | Light mode first — financial data is scanned, not browsed |
| Left-aligned money amounts in lists | Always right-align amounts for easy visual comparison |
| Using red for anything non-financial | Red = expense / over-budget only. Never decorative |
| Circles for category icons | Rounded squares (10px radius) — more modern, more distinct |
| Pure `#000000` text | `#111827` near-black for warmth |
| Stacking multiple primary buttons | One primary (green) + one ghost per action group |
| 3D or animated charts | Flat 2D charts with tap-to-reveal tooltips |
| Gamification (streaks, points, badges) | Clean utility: precise data, clear summaries |
| Small inline fields for amount entry | Full-width large numpad-style amount input |
| Hiding charts when data is sparse | Show empty chart structure with a prompt to add data |
| Generic purple/blue SaaS color scheme | Emerald green + clean white — unmistakably financial |

---

## 11. Design Token Quick Reference

```js
const theme = {
  // Backgrounds
  bg:          "#F7F8FA",   // app background
  surface:     "#FFFFFF",   // cards, nav bar
  surface2:    "#F0F2F5",   // secondary surfaces

  // Borders
  border:      "#E4E7ED",   // all dividers & outlines

  // Brand / Semantic
  accent:      "#1DB954",   // income, positive, primary CTA (green)
  accentSoft:  "#E8F8EE",   // green tinted backgrounds
  red:         "#EF4444",   // expense, overspend, danger
  redSoft:     "#FEF2F2",   // red tinted backgrounds
  blue:        "#3B82F6",   // transfers, neutral
  blueSoft:    "#EFF6FF",   // blue tinted backgrounds
  amber:       "#F59E0B",   // budget warnings
  amberSoft:   "#FFFBEB",   // amber tinted backgrounds

  // Text
  text:        "#111827",   // primary body text
  textSub:     "#6B7280",   // secondary / helper text
  dim:         "#9CA3AF",   // inactive / disabled / placeholder
};
```

---

## 12. Category Color Map Quick Reference

```js
const categoryColors = {
  food:          { bg: "#FFF3E0", text: "#E65100", icon: "🍜" },
  transport:     { bg: "#E3F2FD", text: "#1565C0", icon: "🚗" },
  shopping:      { bg: "#FCE4EC", text: "#C62828", icon: "🛍️" },
  entertainment: { bg: "#EDE7F6", text: "#4527A0", icon: "🎬" },
  health:        { bg: "#E8F5E9", text: "#2E7D32", icon: "💊" },
  bills:         { bg: "#FFF8E1", text: "#F57F17", icon: "⚡" },
  income:        { bg: "#E8F8EE", text: "#1A7A3F", icon: "💰" },
  transfer:      { bg: "#EFF6FF", text: "#1D4ED8", icon: "🔄" },
};
```

---

*These guidelines are a living document. Update them as the design evolves through user testing and the Flutter implementation.*