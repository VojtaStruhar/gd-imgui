# Godot ImGui

GDScript that enables you to build UIs using immediate-mode API.

The UI is actually built with Godot's native Control nodes that you already 
know. This is **not** an actual IMGUI implementation - it just aims to provide
similarly awesome developer experience.

## Why?

You can use Dear ImGui in Godot via the 
[`imgui-godot`](https://github.com/pkdawson/imgui-godot) package. However, the
plugin is implemented via the C# bindings for Dear ImGui and leverages 
GDExtension. That introduces some friction, especially when exporting for web.
It's an unnecessary hassle, especially since IMGUIs are usually only used for 
developer tooling and Godot already has a full blown UI toolkit sitting right 
there!

This project aims to provide IMGUI capabilities with minimal entry barrier.

## How it works

The imgui script expects you to build the UI every frame. While you are
calling widget methods, it compares the calls to the tree of nodes that 
already exists. If input state (e.g. label text) changes, it's updated. If the
layout or order of widgets differs from the current tree, the change is 
detected, nodes are destroyed and recreated to match the new layout.

Unchanged nodes are left completely untouched, so despite the UI being
described every frame, the canvas only redraws when something actually
changes (see Debug > Canvas Redraw).

## Quick start

Copy [`imgui.gd`](imgui.gd) into your project. It's a single file, no
GDExtension, no build step.

Add a `Control`-derived node to your scene, then a plain `Container` as its
child with `imgui.gd` attached — that's your imgui instance. Giving the
`Control` root a real size (e.g. full-rect anchors) is recommended: layouts
like `begin_scroll_v` use it to know how much room they have, and an
embedded imgui (see `embed`) is bounded by it. A zero-sized root still works
(fitted scroll then clamps to the screen instead), it's just less
predictable to reason about.

```gdscript
extends Control
# scene: Control (this script) -> Container ("Imgui", imgui.gd attached)

@onready var g: ImGui = $Imgui

var name := ""

func _process(_delta: float) -> void:
	g.begin_tool_panel() # panel + fitted scroll + margin + vbox
	g.label("Hello!")
	name = g.textfield(name)
	if g.button("Greet") and name != "":
		print("Hello, %s!" % name)
	g.end_tool_panel()
```

Call widget methods once per `_process()` frame, in the same order every
time (skipping a call conditionally is fine; reordering calls between
frames is not — see "How it works" above). Every `begin_*` needs exactly one
matching `end_*` in the same frame. Start from whichever `test_scenes/demo_*.tscn`
is closest to what you're building — they're small, focused, and meant to be
copied from.

## Features (TODOs)

_I'm using [Dear ImGui](https://github.com/ocornut/imgui)'s API as a reference.
Some features have different names to be familiar to Godot developers._

- **Layouts**
  - [x] Row / Column
  - [x] Grid
  - [x] Margin
  - [x] Panel
  - [x] Flow container (`begin_hflow` / `begin_vflow`)
  - [x] Tabs
  - [x] Scroll
	- [x] `begin_scroll_v` now fits its content: it grows with the content and
	  stops at the bottom of the screen, scrolling instead of overflowing —
	  wrap every tool panel in it (or use `begin_tool_panel`)
  - [x] Foldable (`begin_foldable`)
  - [x] Split container (`begin_hsplit` / `begin_vsplit`)
  - [x] Trees (`begin_tree_node`, built on foldables)
  - [x] Draggable windows (`begin_window` — title bar dragging, optional close
	button, clamped to the screen)
  - [x] Aspect ratio container (`begin_aspect_ratio`)
- **Display information**
  - [x] Label
  - [x] TextureRect
  - [x] ColorRect (`color_rect`)
- **Input**
  - [x] Button
  - [x] Number field
  - [x] Text field
  - [x] Combo box (OptionButton)
  - [x] Toggle
  - [x] Checkbox
  - [x] Separators
  - [x] Sliders
  - [x] Text area (TextEdit)
	- [x] Toggle password input (`textfield(text, enabled, secret)`)
  - [x] Color picker (`color_picker`)
  - [x] Radio buttons (`radio`) — built on a real `ButtonGroup`, so Godot
	itself guarantees exactly one option is ever selected
  - [x] Icons on buttons (`button(text, enabled, icon)`)
  - [x] Input capture for game integration: `wants_mouse()` / `wants_keyboard()`
	tell you when mouse/keyboard input belongs to the UI, so polling `Input`
	for game controls doesn't fight the tool panels
- **Styling**
  - [x] `next_*` methods in addition to `push` and `pop` for pretty much
    everything: `next_variation`, `next_font_size`, `next_font_color`,
    `next_separation`, `next_alignment_h/v`, `next_min_size`, `next_tooltip`,
    `next_anchors_preset`
  - [x] Enabled / Disabled inputs
  - [x] [Theme variations](https://docs.godotengine.org/en/stable/tutorials/ui/gui_theme_type_variations.html)
  - [x] Common Theme overrides
    - [x] Separation (`push_separation`)
    - [x] Font size (`push_font_size`)
    - [x] Font color (`push_font_color`)
  - [x] Minimum Control size (`push_min_size` / `next_min_size`)
  - [x] Anchor presets (`next_anchors_preset`) / Expand flags (`push_alignment_h/v`)
  - [x] Label text alignment
  - [x] Rich text label (`rich_label`, BBCode)
  - [x] Container spacing (same as separation — `push_separation`)
  - [x] Tooltips (`next_tooltip`, works even on labels)
  - [x] Texture Rect
    - [x] `texture_rect(texture, stretch, expand)` — stretch mode picks the
      scaling; `EXPAND_IGNORE_SIZE` hands sizing control to the layout
  - [x] The window title bar can be restyled from a theme (an
    `ImGuiWindowTitleBar` `PanelContainer` type variation — see
	`main_theme.tres`) instead of imgui's built-in default
- **Convenience features**
  - Develop commonly used widgets by composing the basics — `vector2`/`vector3`
	(below) are a worked example: no framework changes, just `label()` +
	`spinboxf()` inside a `begin_hbox()`.
  - [x] `begin_tool_panel` — panel + fitted scroll + margin + vbox in one
	call; the recommended root for tool UIs
  - [x] `embed(control)` — inject a node instance you created yourself. It is
	only ever removed from the tree, never freed, so the instance and its
	state persist; imgui doesn't touch its properties
  - [x] `vector2(value, ...)` / `vector3(value, ...)` — compact axis-colored
	number rows, styled like the editor's inspector fields

## Demo scenes

Every widget has a small focused scene in `test_scenes/` — open one in the
editor and run it with F6 (Run Current Scene):

| Scene | Demonstrates |
| --- | --- |
| `demo_scroll_panel` | `begin_tool_panel` / `begin_scroll_v` — panels that scroll instead of leaving the screen |
| `demo_window` | `begin_window` — draggable, closable floating windows |
| `demo_foldable` | `begin_foldable` — collapsible sections |
| `demo_tree` | `begin_tree_node` — nestable tree nodes |
| `demo_flow` | `begin_hflow` — wrapping button rows |
| `demo_split` | `begin_hsplit` / `begin_vsplit` — resizable panes |
| `demo_aspect_ratio` | `begin_aspect_ratio` — fixed w:h child |
| `demo_color_rect` | `color_rect` |
| `demo_color_picker` | `color_picker` |
| `demo_rich_label` | `rich_label` — live BBCode editing |
| `demo_textfield` | `textfield` incl. password mode, `textedit` |
| `demo_radio` | `radio` — exclusive selection via a real `ButtonGroup` |
| `demo_vector` | `vector2` / `vector3` — composite axis-colored number rows |
| `demo_styling` | `push`/`next` font size & color, separation, tooltips |
| `demo_embed` | `embed` — your own persistent node inside the imgui |
| `demo_nested_imgui` | whole demo scenes (own ImGui each) embedded as tabs |
| `demo_texture_stretch` | `texture_rect` stretch & expand modes |
| `cube_manipulator` | a 3D scene manipulated through an imgui panel, with `wants_mouse` / `wants_keyboard` gating the game input |

## Tests

`tests/run_tests.sh` runs the whole suite: a parse check, a headless smoke run
of every scene (any output counts as a failure), headless behavior tests
(scroll fitting, windows, foldables, `embed` ownership, nested imguis) and
windowed visual tests (redraw efficiency, embedded-imgui containment, input
capture) that briefly flash a window. Use `--headless-only` to skip the
windowed ones, and `GODOT=/path/to/godot` to pick the binary.
