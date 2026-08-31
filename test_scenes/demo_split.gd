extends Control
## Demonstrates: begin_hsplit / begin_vsplit — two panes with a draggable
## divider. The divider stays where the user dragged it.

@onready var g: ImGui = $Imgui


func _process(_delta: float) -> void:
	g.next_anchors_preset(Control.PRESET_FULL_RECT)
	g.begin_hsplit(150)

	g.begin_panel()
	g.begin_margin(10)
	g.begin_vbox()
	g.push_font_size(22)
	g.label("Demo: Split containers")
	g.pop_font_size()
	g.label("Drag the dividers between the panes.")
	g.label("This is the left pane of an hsplit.")
	g.end_vbox()
	g.end_margin()
	g.end_panel()

	g.begin_vsplit(150)

	g.begin_panel()
	g.begin_margin(10)
	g.begin_vbox()
	g.label("Top-right pane of a nested vsplit.")
	g.end_vbox()
	g.end_margin()
	g.end_panel()

	g.begin_panel()
	g.begin_margin(10)
	g.begin_vbox()
	g.label("Bottom-right pane of a nested vsplit.")
	g.end_vbox()
	g.end_margin()
	g.end_panel()

	g.end_vsplit()

	g.end_hsplit()
