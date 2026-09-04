extends SceneTree
## Headless checks for nested imguis (demo_nested_imgui): only the active
## tab's scene is in the tree; detached scenes pause but keep all state, and
## the very same nodes return on tab switch.
## Run: godot --headless --path . -s tests/test_nested.gd

var frames := 0
var failed := false
var scene: Node
var foldables: Control
var picker: Control
var rows: Control
var audio: FoldableContainer
var tab_bar: TabBar


func check(name: String, condition: bool) -> void:
	if condition:
		print("  ok - ", name)
	else:
		failed = true
		print("FAIL - ", name)


func _tool_vbox(demo: Control) -> Control:
	return demo.get_node("Imgui").get_child(0).get_child(0).get_child(0).get_child(0)


func _initialize() -> void:
	scene = (load("res://test_scenes/demo_nested_imgui.tscn") as PackedScene).instantiate()
	root.add_child(scene)


func _process(_delta: float) -> bool:
	frames += 1
	match frames:
		5:
			foldables = scene.get("foldables")
			picker = scene.get("picker")
			rows = scene.get("scroll_rows")
			tab_bar = scene.get_node("Imgui").get_child(0).get_child(2).get_child(0)
			check("three tabs exist", tab_bar.tab_count == 3)
			check("only the active tab's scene is in the tree",
				foldables.is_inside_tree() and not picker.is_inside_tree() and not rows.is_inside_tree())
			audio = _tool_vbox(foldables).get_child(3)
			audio.folded = true
		8:
			tab_bar.current_tab = 1
		11:
			check("tab switch swaps the embedded scene", picker.is_inside_tree() and not foldables.is_inside_tree())
			check("detached scene stays alive", is_instance_valid(foldables) and is_instance_valid(audio))
			rows.set("row_count", 15) # mutate while detached (not processing)
			tab_bar.current_tab = 2
		14:
			check("detached mutation applies on re-embed",
				rows.is_inside_tree() and _tool_vbox(rows).get_child_count() - 6 == 15)
			tab_bar.current_tab = 0
		17:
			check("the same nodes come back", foldables.is_inside_tree() and audio.is_inside_tree())
			check("fold state survived the round trip", audio.folded)
			print("PASS" if not failed else "FAILED")
			quit(1 if failed else 0)
			return true
	return false
