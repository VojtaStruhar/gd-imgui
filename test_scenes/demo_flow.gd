extends Control
## Demonstrates: begin_hflow — like an hbox, but children wrap to the next row
## when they run out of horizontal space.

@onready var g: ImGui = $Imgui

var button_count := 14


func _process(_delta: float) -> void:
	g.next_anchors_preset(Control.PRESET_FULL_RECT)
	g.begin_tool_panel()

	g.push_font_size(22)
	g.label("Demo: Flow layout")
	g.pop_font_size()
	g.label("Buttons wrap to the next row when they run out of width.\nResize the game window to see them reflow.")
	g.begin_grid(2)
	g.label("Button count:")
	button_count = g.spinbox(button_count, 0, 60)
	g.end_grid()
	g.separator()

	g.begin_hflow()
	for i in button_count:
		g.button("Button %d" % i)
	g.end_hflow()

	g.end_tool_panel()
