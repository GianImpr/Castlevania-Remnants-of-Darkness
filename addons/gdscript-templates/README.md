# GDScript Templates

![GDScript Templates](https://github.com/rychtar/gdscript-templates/blob/main/media/gdscript-templates-thumbnail.webp?raw=true)

Code snippets for the Godot 4 script editor. Type a keyword, press `Ctrl+E` (or pick it
from Godot's code completion) and it expands into code.

```
printd health  →  print("health: ", health)
vec 10 20      →  Vector2(10, 20)
fori 5         →  for i in range(5):
```

## Installation

Copy `addons/gdscript-templates` into your project's `addons` folder and enable
**GDScript Templates** in **Project → Project Settings → Plugins**.

Requires Godot 4.2+ (tested with 4.7).

## Usage

| Key | Action |
|-----|--------|
| `Ctrl+E` | Expand the template before the cursor (opens the template browser when there is none) |
| `Enter` / `Tab` | Expand a template picked in Godot's code completion |
| `Ctrl+Space` | Open the template browser |
| `Tab` | Go to the next parameter |
| `Shift+Tab` | Go to the previous parameter |
| `Esc` | Stop jumping between parameters |

Words after the keyword fill the template parameters in order. Parameters you
skip get their default value (or their name) and are selected one by one:
`vec 10` gives `Vector2(10, 0)` with `0` selected, so you can type its value and
press `Tab` to go to the next one. A parameter used more than once (like `{name}`
in `prop`) only needs to be typed once. Put a value with spaces in quotes:
`func move "delta: float"`. Quotes also keep a value that is itself a keyword from being
taken for the template: `if "input"`.

Select some code and press `Ctrl+E` (or `Ctrl+Space`) to wrap it in a template:
`if`, `ife`, `for`, `fori`, `while`, `region`, `isval`, `isnull`, `dicthas` and
`evact` put the selected code inside the new block.

Templates also show up in Godot's own code completion, marked `(template)`, after
you type the first two letters of a keyword. Pick one with `Enter` or `Tab` and it
expands like with `Ctrl+E`.

The template browser (`Ctrl+Space`) lists all templates by category, with the ones
you use the most at the top, and shows a preview. Type to search keywords,
descriptions and categories, then press `Enter` or `Tab` to insert the selected template.

There are more than 100 built-in templates: functions (`func`, `ready`, `process`),
variables (`export`, `onready`, `prop`), control flow (`if`, `ife`, `for`, `fori`, `match`),
signals (`signal`, `sigcon`, `awaitsig`), nodes (`addch`, `getnode`), tweens,
movement (`move2d`), a state machine (`statem`), files (`fread`, `fwrite`), math and more.

## Custom templates

Open **Project → Tools → GDScript Templates...** (or **Edit Templates...** in the
browser). You can add your own templates or change the built-in ones. A changed
built-in template can be reverted to the original.

Your templates are saved to `gdscript_templates.json` in the Godot editor config
folder, so all your projects use the same file. A template can also be available
in **This project only**: project templates are saved to `res://.gdscript_templates.json`,
which you can commit and share with your team. Changes made to these files outside
Godot are picked up automatically. Template syntax:

```json
{
  "myloop": "for {item} in {collection}:\n\tif {item}.{property}:\n\t\t|CURSOR|",
  "wait": "await get_tree().create_timer({seconds=0.5}).timeout",
  "debugonly": "if OS.is_debug_build():\n\t{selection}|CURSOR|",
  "log": {
    "body": "print(\"{value}: \", {value})|CURSOR|",
    "description": "Print a value with its name",
    "category": "Debug"
  }
}
```

- `{name}` is a parameter
- `{name=value}` is a parameter with a default value (`{name=}` for an empty one)
- `{selection}` is the code that was selected when the template was inserted
- `|CURSOR|` is where the cursor ends up after expanding
- `\t` is one indent level (converted to spaces if your editor uses spaces)
- `description` and `category` are optional, they are shown in the template browser

## Settings

Go to **Editor → Editor Settings → Plugins → GDScript Templates**. Godot only
shows plugin settings when **Advanced Settings** (top right) is turned on.

- **Use Default Templates**: turn off to use only your own templates
- **Show In Code Completion**: turn off to keep templates out of Godot's code completion
- **Show Templates Shortcut**, **Expand Template Shortcut**: keyboard shortcuts

`Ctrl+Space` replaces Godot's own "request code completion" shortcut in the script
editor. On macOS it is also used to switch keyboard languages, so it may not reach
Godot at all. If either is a problem, set a different **Show Templates Shortcut**.


MIT
