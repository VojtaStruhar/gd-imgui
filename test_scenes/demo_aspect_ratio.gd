extends Control
## Demonstrates: begin_aspect_ratio — the child keeps a fixed width:height
## ratio no matter how the container is sized.

@onready var g: ImGui = $Imgui

var ratio := 1.78


func _process(_delta: float) -> void:
	g.begin_tool_panel()

	g.push_font_size(22)
	g.label("Demo: Aspect ratio container")
	g.pop_font_size()
	g.begin_grid(2)
	g.next_min_width(120)
	g.label("Ratio (w:h)")
	g.push_alignment_h(SizeFlags.SIZE_EXPAND_FILL)
	ratio = g.slider_h(ratio, 0.25, 4.0, 0.01)
	g.pop_alignment_h()
	g.end_grid()
	g.label("%.2f : 1 — the blue rectangle keeps this ratio inside a fixed 400x260 area" % ratio)
	g.separator()

	g.next_min_size(400, 260)
	g.begin_aspect_ratio(ratio)
	g.color_rect(Color(0.3, 0.55, 0.9))
	g.end_aspect_ratio()

	g.end_tool_panel()
