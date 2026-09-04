extends SceneTree
## Windowed check for wants_mouse() / wants_keyboard(): hovering the panel or
## focusing one of its fields captures input; elsewhere the game gets it.
## Run: godot --path . -s tests/test_input_capture.gd   (a window flashes briefly)
##
## Each step polls for its expected condition instead of trusting a fixed
## frame count: under system load (e.g. this suite launching several Godot
## processes back to back) GUI hover/focus dispatch can lag a fixed count of
## frames, and that's not something this test is trying to measure — a real
## bug still fails, once MAX_WAIT_FRAMES is exhausted.

const MAX_WAIT_FRAMES := 120

var frames := 0
var failed := false
var scene: Node
var g: ImGui
var step := 0
var wait_start := 0


func check(name: String, condition: bool) -> void:
	if condition:
		print("  ok - ", name)
	else:
		failed = true
		print("FAIL - ", name)


func _initialize() -> void:
	scene = (load("res://test_scenes/cube_manipulator.tscn") as PackedScene).instantiate()
	root.add_child(scene)


func _spinbox() -> SpinBox:
	var vbox: Control = g.get_child(0).get_child(0).get_child(0)
	return vbox.get_child(1).get_child(1)


func _move_mouse(to: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = to
	motion.global_position = to
	Input.parse_input_event(motion)


## Waits (bounded) for [param condition] to become true, then runs [param on_ready]
## and advances to the next step. Fails and advances anyway once the budget
## runs out, so a real regression still terminates the test instead of hanging.
func _await(name: String, condition: Callable, on_ready: Callable) -> void:
	if condition.call():
		check(name, true)
		on_ready.call()
		step += 1
		wait_start = frames
	elif frames - wait_start > MAX_WAIT_FRAMES:
		check(name, false)
		on_ready.call()
		step += 1
		wait_start = frames


func _process(_delta: float) -> bool:
	frames += 1
	if frames == 5:
		g = scene.get_node("CanvasLayer/ImGui")
		_move_mouse(Vector2(100, 100)) # over the panel
		step = 1
		wait_start = frames
		return false

	match step:
		1:
			_await("wants_mouse over the panel", func(): return g.wants_mouse(),
				func(): _move_mouse(Vector2(800, 450))) # empty space
		2:
			_await("no wants_mouse over the game world", func(): return not g.wants_mouse(),
				func(): pass)
		3:
			check("no wants_keyboard without focus", not g.wants_keyboard())
			_spinbox().get_line_edit().grab_focus()
			step += 1
			wait_start = frames
		4:
			_await("wants_keyboard while editing a field", func(): return g.wants_keyboard(),
				func(): _spinbox().get_line_edit().release_focus())
		5:
			_await("no wants_keyboard after focus is released", func(): return not g.wants_keyboard(),
				func(): pass)
		6:
			print("PASS" if not failed else "FAILED")
			quit(1 if failed else 0)
			return true
	return false
