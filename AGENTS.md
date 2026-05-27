# Codex Working Notes

## Current Branch And Target

- Latest/default branch for Codex Cloud: `main`.
- Previous handoff branch: `codex/update-calculator-1-0`.
- Current active file for this branch: `CNC Calculator 1.0.html`.
- Historical/test file: `Cnc Calculator UI Test.html`. Do not edit it unless the user explicitly switches back to it.
- Keep the app as a single-file HTML calculator unless the user explicitly asks for a build system.

## Hard Rules

- Do not deploy to Netlify unless the user explicitly asks for that exact deployment.
- Keep the spelling `Panneling`.
- Preserve 7mm sheet margin and 7mm spacing between nested front parts.
- Do not stage or rewrite unrelated local files. In this workspace there may be untracked tools, gadgets, vendor files, and HTML copies.
- Prefer small, focused edits and run an inline script syntax check after JavaScript changes.

## Local Validation

PowerShell syntax check for inline scripts:

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

Local static server:

```powershell
cd "C:\Users\ednei\Documents\CNC App"
python -m http.server 8765 --bind 127.0.0.1
```

Open:

```text
http://127.0.0.1:8765/CNC%20Calculator%201.0.html
```

The in-app browser may block direct `file://` automation, so use the local server for visual QA when possible.

## Git Flow

Before working:

```powershell
git fetch origin
git checkout main
git pull --ff-only
```

After working:

```powershell
git status --short
git add -- "CNC Calculator 1.0.html" AGENTS.md docs/CODEX_CLOUD_HANDOFF_2026-05-27.md README.md
git commit -m "Describe the calculator change"
git push
```

Only add files intentionally changed for the current task.
