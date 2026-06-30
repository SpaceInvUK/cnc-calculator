# Codex Working Notes

## Current Branch And Target

- Latest/default branch for Codex Cloud: `main`.
- Previous handoff branch: `codex/update-calculator-1-0`.
- Current official version: `1.0`.
- Current active GitHub Pages entry point: `Cnc Calculator UI Test.html`.
- Current local 1.0 mirror: `CNC Calculator 1.0.html`.
- Keep those two HTML files synchronized when updating the official 1.0 calculator.
- Published URL: `https://spaceinvuk.github.io/cnc-calculator/Cnc%20Calculator%20UI%20Test.html`.
- Keep the app as a single-file HTML calculator unless the user explicitly asks for a build system.
- Do not recreate old calculator copies or prototype HTML files unless the user explicitly asks for a separate experiment.

## Hard Rules

- Do not deploy to Netlify unless the user explicitly asks for that exact deployment.
- Keep the spelling `Paneling`.
- Preserve 7mm sheet margin and 7mm spacing between nested front parts.
- Do not stage or rewrite unrelated local files. In this workspace there may be untracked tools, gadgets, vendor files, and HTML copies.
- Prefer small, focused edits and run an inline script syntax check after JavaScript changes.

## Local Validation

PowerShell syntax check for inline scripts:

```powershell
@'
const fs = require('fs');
for (const file of ['Cnc Calculator UI Test.html', 'CNC Calculator 1.0.html']) {
  const html = fs.readFileSync(file, 'utf8');
  const scripts = [...html.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/gi)].map(m => m[1]);
  for (let i = 0; i < scripts.length; i++) new Function(scripts[i]);
  console.log(`${file}: checked ${scripts.length} inline script(s)`);
}
'@ | node -
```

Local static server:

```powershell
cd "C:\Users\ednei\Documents\CNC App"
python -m http.server 8765 --bind 127.0.0.1
```

Open:

```text
http://127.0.0.1:8765/Cnc%20Calculator%20UI%20Test.html
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
git add -- "Cnc Calculator UI Test.html" "CNC Calculator 1.0.html" AGENTS.md README.md
git commit -m "Describe the calculator change"
git push
```

Only add files intentionally changed for the current task.
