extends Node3D

@onready var cube: MeshInstance3D = $Cube
@onready var g: ImGui = $CanvasLayer/ImGui

func _process(delta: float) -> void:
	g.begin_panel()
	g.begin_margin(10)
	g.begin_vbox()
	g.label("Position")
	g.begin_grid(2)
	
	g.label("X:")
	cube.global_position.x = g.spinbox(roundi(cube.global_position.x), -15, 5)
	g.label("Y:")
	cube.global_position.y = g.spinbox(roundi(cube.global_position.y), -15, 5)
	g.label("Z:")
	cube.global_position.z = g.spinboxf(cube.global_position.z, -15, 5)
	
	g.end_grid()

	
	g.separator_h()
	
	g.label("Scale")
	g.begin_grid(2)
	
	g.label("X:")
	cube.scale.x = g.slider_h(cube.scale.x, 1, 5)
	g.label("Y:")
	cube.scale.y = g.slider_h(cube.scale.y, 1, 5)
	g.label("Z:")
	cube.scale.z = g.spinboxf(cube.scale.z, 1, 5)
	
	
	g.end_grid()

	g.separator_h()
	g.label("Hold LMB outside the panel to spin the cube.\nPress R to reset — ignored while editing a field.")
	g.end_vbox()

	g.end_margin()
	g.end_panel()

	# Game input, gated by the UI's input capture: polling Input directly
	# bypasses GUI consumption, so ask the imgui first.
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not g.wants_mouse():
		cube.rotate_y(delta * 2.0)
	if Input.is_key_pressed(KEY_R) and not g.wants_keyboard():
		cube.position = Vector3.ZERO
		cube.rotation = Vector3.ZERO
		cube.scale = Vector3.ONE


func _on_move_x_pressed() -> void:
	cube.position += Vector3(randi() % 3 - 1, randi() % 3 - 1, randi() % 3 - 1)


func _on_scale_x_pressed() -> void:
	cube.scale.x += 0.1
