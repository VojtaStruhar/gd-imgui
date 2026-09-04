extends SceneTree
## Headless checks for vector2()/vector3(): composite widgets built purely
## from label()/spinboxf()/begin_hbox() — round-trip the value, and the whole
## call reads as a single widget to the caller (one cursor slot consumed).
## Run: godot --headless --path . -s tests/test_composite_widgets.gd

var frames := 0
var failed := false
var g: ImGui
var pos := Vector3(1, 2, 3)
var offset := Vector2(4, 5)


func check(name: String, condition: bool) -> void:
	if condition:
		print("  ok - ", name)
	else:
		failed = true
		print("FAIL - ", name)


func _initialize() -> void:
	var root_ctrl := Control.new()
	root.add_child(root_ctrl)
	g = ImGui.new()
	root_ctrl.add_child(g)


func _process(_delta: float) -> bool:
	frames += 1
	g.label("before")
	pos = g.vector3(pos, -100, 100)
	offset = g.vector2(offset, -100, 100)
	g.label("after")

	if frames == 2:
		check("initial value round-trips unchanged", pos == Vector3(1, 2, 3))
		check("caller sees 4 top-level widgets, not the internals", g.get_child_count() == 4)
		var row: HBoxContainer = g.get_child(1)
		check("vector3 renders as one hbox with 3 X/Y/Z pairs", row is HBoxContainer and row.get_child_count() == 6)
		check("axis labels read X, Y, Z in order",
			(row.get_child(0) as Label).text == "X" and (row.get_child(2) as Label).text == "Y" and (row.get_child(4) as Label).text == "Z")
		# Simulate a user edit on the Y spinbox (index 3: X label, X box, Y label, Y box, ...).
		(row.get_child(3) as SpinBox).get_line_edit().text = "9"
		(row.get_child(3) as SpinBox).apply()
	if frames == 4:
		check("editing Y through the real widget updates the returned Vector3", pos == Vector3(1, 9, 3))
		check("X and Z are untouched", pos.x == 1 and pos.z == 3)
		var row2: HBoxContainer = g.get_child(2)
		check("vector2 renders as one hbox with 2 X/Y pairs", row2 is HBoxContainer and row2.get_child_count() == 4)
		print("PASS" if not failed else "FAILED")
		quit(1 if failed else 0)
		return true
	return false
