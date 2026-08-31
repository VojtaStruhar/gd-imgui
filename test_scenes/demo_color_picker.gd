extends Control
## Demonstrates: color_picker — a compact color input (ColorPickerButton).

@onready var g: ImGui = $Imgui

const DEFAULT_TINT := Color(0.4, 0.7, 1.0)

var tint := DEFAULT_TINT


func _process(_delta: float) -> void:
	g.begin_tool_panel()

	g.push_font_size(22)
	g.label("Demo: Color picker")
	g.pop_font_size()
	g.begin_grid(2)
	g.label("Tint:")
	tint = g.color_picker(tint)
	g.label("Hex:")
	g.label("#" + tint.to_html())
	g.end_grid()
	g.separator()

	g.label("Preview:")
	g.next_min_size(200, 60)
	g.color_rect(tint)
	if g.button("Reset"):
		tint = DEFAULT_TINT

	g.end_tool_panel()
