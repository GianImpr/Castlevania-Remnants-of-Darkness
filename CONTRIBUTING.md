# Contributing Guidelines

Thank you for considering a contribution to Castlevania: Remnants of Darkness!
This document outlines the process and expectations for contributions.
> **Important:** Before starting, please read the [README](README.md) for an overview of the project and its directories.

## Ground rules
- Always use English for identifiers, comments, documentation, commit messages, and filenames.
- Preserve existing conventions and style: GDScript in Godot Engine. Match node naming, script structure, signal usage, and formatting.
- Keep gameplay behavior stable. If a change alters existing mechanics (combat, movement, items, save data), describe it in the PR and update all affected scenes and scripts in the same change.
- Minimize blast radius: prefer the smallest coherent change set; avoid unrelated refactors or mass renames.
- Write clear, maintainable code. Prioritize readability over cleverness.
- Do not modify files under `addons/` unless the change is intentional and explained in the PR, since they are third-party plugins.

## Repository structure
- `SampleProject`: most of the project's data (scripts, scenes, enemies, items, menus).
- `scenes`: some of the game's scenes.
- `assets`: images, spritesheets, textures, sounds, and soundtracks.
- `addons`: Godot addons (G.U.I.D.E, Metroidvania System, Input Helper, Input Buffer, etc.).
- `guide_examples`: guides for the G.U.I.D.E addon.
- `rooms`: old builds of room scenes, nothing of value.

## Development environment stack
- Godot Engine, using the version stated in the [README](README.md) and `project.godot`. The project is not compatible with older versions of the engine.
- GDScript.
- Any code editor you like (the built-in Godot editor, VS Code, JetBrains IDEs).
- Git, with a GitHub fork of the repository.

## Running & testing
- Open `project.godot` in Godot and run the project (F5) or the scene you changed (F6).
- Manually test your change in-game: the happy path and at least one edge case (for example, interrupting an action with a menu or a hit).
- Check the Godot Output and Debugger panels for new errors or warnings.
- Include screenshots or a short video in the PR for visual or gameplay changes.

## Scenes, resources & assets
- Avoid committing `.import` files and other editor-generated changes that are unrelated to your work. Opening the project in a different Godot version can regenerate them in bulk.
- Do not commit the `.godot/` folder.
- Keep line endings consistent (LF, see `.gitattributes`) to avoid whole-file diffs.
- Place new assets in the matching folder under `assets/` and keep file names descriptive.
- Only submit assets you have the right to use, and add credits in the README when required.
- Prefer small, reviewable scene changes. Avoid re-saving scenes you did not intend to modify.

## Code quality
- Use typed GDScript where the surrounding code does.
- Remove debug prints and commented-out code before submitting.
- Be mindful of per-frame work in `_process` and `_physics_process`.
- Avoid committing secrets, tokens, or personal data.

## Git workflow
- Fork the repository and add the original as `upstream`.
- Create feature branches from the latest `upstream/main`.
- Keep commits small and atomic.
- Use branch names with a type prefix, for example `fix/guard-walk-stuck`, `feat/new-enemy`, `docs/add-contributing`.
- Commit messages follow the existing history: a short, imperative, descriptive English subject, for example:
  - `Fixed Hector being stuck on GuardWalk state while opening the menu`
  - `Added hitbox when Dullahan uses his laser`
  - `Updated boss bar HUD`
- In PR descriptions: include rationale, risk, and testing notes; link to related issues.

### Quick start
```bash
# one time
git clone https://github.com/<your-user>/Castlevania-Remnants-of-Darkness.git
cd Castlevania-Remnants-of-Darkness
git remote add upstream https://github.com/GianImpr/Castlevania-Remnants-of-Darkness.git

# for each contribution
git fetch upstream
git checkout -b fix/my-change upstream/main
# ...make your changes, then check what actually changed
git status
git diff --stat
# stage only the files you meant to change
git add -p
git commit -m "Fixed <what you fixed>"
git push -u origin fix/my-change
# then open a pull request against the original repository's main branch
```

Optional: check for script errors without opening the editor.
```bash
godot --headless --path . --quit
```

## Pull requests
- Target the `main` branch of the original repository.
- Keep each PR focused on a single fix or feature.
- For larger changes, open an issue or contact the maintainer first (Discord tag in the README) to agree on the approach.
- Address review feedback by pushing new commits to the same branch.

## License & copyright
- Ensure changes comply with the repository license and the copyright notes in the [README](README.md).
- Castlevania is owned by Konami. Contributions must not include spoilers or reveal the story of the games.

## Questions
- For project-specific questions, check the [README](README.md) or contact the maintainer on Discord (tag in the README).
