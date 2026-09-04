extends SceneTree
## Headless check for a specific reconciliation-model edge case: every nesting
## level gets its trailing-children cleanup from its own end_*() call, but the
## root level (direct children of the ImGui node) has no such call — nothing
## else visits it. _process() has to do that pruning itself, using __cursor's
## value from the end of the previous frame, before resetting it to 0.
## Run: godot --headless --path . -s tests/test_toplevel_prune.gd

var frames := 0
var failed := false
var g: ImGui
var show_extra := true


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
	g.begin_panel() # always top-level index 0
	g.label("main")
	g.end_panel()
	if show_extra:
		g.begin_panel() # top-level index 1, only while show_extra
		g.label("extra")
		g.end_panel()

	if frames == 3:
		check("second top-level panel exists while called", g.get_child_count() == 2)
		show_extra = false
	if frames == 6:
		check("dropped top-level panel is pruned, not leaked", g.get_child_count() == 1)
		print("PASS" if not failed else "FAILED")
		quit(1 if failed else 0)
		return true
	return false
