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
- **Convenience features**
  - Develop commonly used widgets by composing the basics? This would probably inherit `ImGui` class.
  - [x] `begin_tool_panel` — panel + fitted scroll + margin + vbox in one
    call; the recommended root for tool UIs
  - [x] `embed(control)` — inject a node instance you created yourself. It is
    only ever removed from the tree, never freed, so the instance and its
    state persist; imgui doesn't touch its properties

