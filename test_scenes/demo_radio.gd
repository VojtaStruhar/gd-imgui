extends Control
## Demonstrates: radio — mutually exclusive options built on a real
## ButtonGroup, so Godot itself guarantees only one is ever selected.

@onready var g: ImGui = $Imgui

const QUALITY: Array[String] = ["Low", "Medium", "High", "Ultra"]
const MODE: Array[String] = ["Solo", "Co-op", "Versus"]

var quality := 1
var mode := 0


func _process(_delta: float) -> void:
	g.begin_tool_panel()

	g.push_font_size(22)
	g.label("Demo: Radio buttons")
	g.pop_font_size()
	g.label("Exactly one option is selected at all times — Godot's own\nButtonGroup enforces it, not the imgui.")
	g.separator()

	g.label("Quality:")
	quality = g.radio(quality, QUALITY)
	g.label("Selected: %s" % QUALITY[quality])
	g.separator()

	g.label("Game mode:")
	mode = g.radio(mode, MODE)
	g.label("Selected: %s" % MODE[mode])

	g.end_tool_panel()
