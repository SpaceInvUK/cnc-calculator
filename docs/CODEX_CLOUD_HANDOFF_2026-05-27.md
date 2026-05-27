# Codex Cloud Handoff - 2026-05-27

## Repository

- GitHub repo: `https://github.com/SpaceInvUK/cnc-calculator`
- Branch to continue from in Codex Cloud: `main`
- Previous handoff branch: `codex/update-calculator-1-0`
- Current working target: `CNC Calculator 1.0.html`

## How To Continue On Another PC Or Codex Cloud

```powershell
git clone https://github.com/SpaceInvUK/cnc-calculator.git
cd cnc-calculator
git checkout main
```

Open locally:

```powershell
python -m http.server 8765 --bind 127.0.0.1
```

Then open:

```text
http://127.0.0.1:8765/CNC%20Calculator%201.0.html
```

When returning to this PC:

```powershell
cd "C:\Users\ednei\Documents\CNC App"
git fetch origin
git checkout main
git pull --ff-only
```

## What Was Last Changed In `CNC Calculator 1.0.html`

- Removed the fixed/top `Round?` command button.
- Changed sheet pricing logic so used sheets bill as full sheets only. Old saved `1/3` or `2/3` values normalize to full sheet billing.
- Added `Remove Room` control for Panneling rooms.
- Room removal now works even when there is only one room; it replaces the last room with a fresh empty room.
- Wall removal can leave zero walls instead of silently recreating one.
- Per-wall skirting controls were added: inherit room default, force Yes/No, and custom skirting height.
- Selected physical panneling panels can be deleted with Delete/Backspace or the row delete button without stretching/rebuilding neighboring panels.
- Individual panel orientation can be changed even when the wall or imported JSON originally made all panels vertical.

## Current User Intent For The 1.0 File

The user has moved active work from `Cnc Calculator UI Test.html` to `CNC Calculator 1.0.html`.

Main requested direction:

- Doors and Panneling should share cleaner pricing behavior.
- The app should no longer expose half-sheet, third-sheet, or two-third-sheet charging as the active pricing model.
- Panneling Room Setup must support Add Room and Remove Room.
- Loaded jobs, including the James JSON example, must allow removing rooms, walls, openings, and selected panels.
- Skirting starts from a room/default value but can be overridden per wall.
- Selected panels should be deletable without recalculating the whole wall.
- Individual panels from imported vertical wall jobs must be editable back to horizontal.
- Smart Takeoff needs more accepted variations, but the exact new parsing examples still need to be supplied by the user.

## Important Existing Rules

- Keep spelling `Panneling`.
- Do not deploy to Netlify unless explicitly requested.
- Keep the app single-file unless explicitly requested otherwise.
- Preserve 7mm sheet margin and 7mm spacing for normal/front nesting.
- Keep labels physically meaningful, for example `Room Name Wall 1 - P2V`.
- DXF, wall preview, and sheet preview should use the same physical panel geometry.
- Inputs must allow decimals when typed and should not move the cursor to the left while typing.
- Avoid changing dimensions from imported customer JSON unless the user explicitly asks to change the job data.

## QA Notes

Run this syntax check after editing:

```powershell
@'
const fs = require('fs');
const file = 'CNC Calculator 1.0.html';
const html = fs.readFileSync(file, 'utf8');
const scripts = [...html.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/gi)].map(m => m[1]);
for (let i = 0; i < scripts.length; i++) new Function(scripts[i]);
console.log(`Checked ${scripts.length} inline script(s)`);
'@ | node -
```

Recent result before this handoff:

```text
Checked 2 inline script(s)
```

The Codex in-app browser can block `file://` navigation. Prefer the local `http://127.0.0.1:8765/...` URL for browser QA.

## Local Workspace Caution

The local PC currently has untracked files that were not part of the calculator handoff. Do not stage them unless the user explicitly asks:

- `Cnc Calculator UI Test - Copy.html`
- `My Wood Job Creator - New Layout.html`
- `docs/VECTRIC_GADGET_SETUP.md`
- `gadgets/`
- `tools/`
- `vendor/`
