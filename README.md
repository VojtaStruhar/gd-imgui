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

## Features (TODOs)

_I'm using [Dear ImGui](https://github.com/ocornut/imgui)'s API as a reference.
Some features have different names to be familiar to Godot developers._

- **Layouts**
  - [x] Row / Column
  - [x] Grid
  - [x] Margin
  - [x] Panel
  - [ ] Flow container
  - [x] Tabs
  - [x] Scroll
    - [ ] TODO: Revisit this one!
  - [ ] Foldable
  - [ ] Split container
  - [ ] Trees
  - [ ] OPTIONAL: Draggable windows (similar to Dear ImGui) (This is something imgui's control node can handle via Godot)
  - [ ] Aspect ratio container
- **Display information**
  - [x] Label
  - [x] TextureRect
  - [ ] ColorRect
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
    - [ ] Toggle password input
  - [ ] Color picker
- **Styling**
  - [ ] Add `next_*` methods in addition to `push` and `pop` for pretty much everything!
  - [x] Enabled / Disabled inputs
  - [x] [Theme variations](https://docs.godotengine.org/en/stable/tutorials/ui/gui_theme_type_variations.html)
  - [ ] Common Theme overrides
    - [ ] Separation
    - [ ] Font size
    - [ ] Font color
  - [ ] Minimum Control size
  - [ ] Anchor presets / Expand flags
  - [x] Label text alignment
  - [ ] Rich text label
  - [ ] Container spacing
  - [ ] Tooltips
  - [ ] Texture Rect
    - Come up with the most useful stretch / sizing modes and make them easy to access.
- **Convenience features**
  - Develop commonly used widgets by composing the basics? This would probably inherit `ImGui` class.
