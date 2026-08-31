extends Control
## Demonstrates: color_rect — solid-colored rectangles. They have no size of
## their own, so give them one with next_min_size().

@onready var g: ImGui = $Imgui

var hue := 0.6


func _process(_delta: float) -> void:
	g.begin_tool_panel()

	g.push_font_size(22)
	g.label("Demo: Color rect")
	g.pop_font_size()
	g.begin_grid(2)
	g.label("Hue")
	g.push_alignment_h(SizeFlags.SIZE_EXPAND_FILL)
	hue = g.slider_h(hue, 0.0, 1.0, 0.01)
	g.pop_alignment_h()
	g.end_grid()
	g.separator()

	g.next_min_size(0, 60)
	g.color_rect(Color.from_hsv(hue, 0.7, 0.9))

	g.begin_hbox()
	for i in 5:
		g.next_min_size(48, 48)
		g.color_rect(Color.from_hsv(wrapf(hue + i * 0.08, 0.0, 1.0), 0.7, 0.9))
	g.end_hbox()

	g.end_tool_panel()
