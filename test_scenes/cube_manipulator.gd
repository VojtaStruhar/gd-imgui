extends Node3D

@onready var cube: MeshInstance3D = $Cube
@onready var g: ImGui = $CanvasLayer/ImGui

func _process(_delta: float) -> void:
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
	g.end_vbox()
	
	g.end_margin()
	g.end_panel()


func _on_move_x_pressed() -> void:
	cube.position += Vector3(randi() % 3 - 1, randi() % 3 - 1, randi() % 3 - 1)


func _on_scale_x_pressed() -> void:
	cube.scale.x += 0.1
