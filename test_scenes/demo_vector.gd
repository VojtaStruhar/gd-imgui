extends Control
## Demonstrates: vector2 / vector3 — compact axis-colored number rows for
## editing a Vector2/Vector3, built entirely by composing label()/spinboxf().

@onready var g: ImGui = $Imgui

var object_position := Vector3.ZERO
var object_scale := Vector3.ONE
var offset := Vector2(10, 10)


func _process(_delta: float) -> void:
	g.begin_tool_panel()

	g.push_font_size(22)
	g.label("Demo: Vector rows")
	g.pop_font_size()
	g.label("A composite widget, not a framework primitive — see vector3()\nin imgui.gd: just label() + spinboxf() inside a begin_hbox().")
	g.separator()

	g.begin_grid(2)
	g.label("Position:")
	object_position = g.vector3(object_position, -100, 100, 0.1)
	g.label("Scale:")
	object_scale = g.vector3(object_scale, 0.1, 10, 0.05)
	g.label("UI offset:")
	offset = g.vector2(offset, -50, 50)
	g.end_grid()

	g.end_tool_panel()
