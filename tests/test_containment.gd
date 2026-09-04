extends SceneTree
## Windowed check that an embedded imgui is bounded by the rect it was given:
## its fitted tool panels stop at the embed box's bottom edge and scroll,
## instead of overflowing toward the screen bottom. Needs a real window — the
## headless viewport is smaller than the embed box, which would mask the bound.
## Run: godot --path . -s tests/test_containment.gd   (a window flashes briefly)

var frames := 0
var failed := false
var scene: Node
var foldables: Control
var rows: Control
var tab_bar: TabBar


func check(name: String, condition: bool) -> void:
	if condition:
		print("  ok - ", name)
	else:
		failed = true
		print("FAIL - ", name)


func _inner_panel(demo: Control) -> Control:
	return demo.get_node("Imgui").get_child(0)


func _initialize() -> void:
	scene = (load("res://test_scenes/demo_nested_imgui.tscn") as PackedScene).instantiate()
	root.add_child(scene)


func _process(_delta: float) -> bool:
	frames += 1
	match frames:
		5:
			foldables = scene.get("foldables")
			rows = scene.get("scroll_rows")
			tab_bar = scene.get_node("Imgui").get_child(0).get_child(2).get_child(0)
			var vbox: Control = _inner_panel(foldables).get_child(0).get_child(0).get_child(0)
			for i in [3, 4, 5]:
				(vbox.get_child(i) as FoldableContainer).folded = false
		10:
			var panel := _inner_panel(foldables)
			check("unfolded content stays inside the embed box",
				panel.get_global_rect().end.y <= foldables.get_global_rect().end.y + 1.0)
			rows.set("row_count", 40)
			tab_bar.current_tab = 2
		16:
			var panel := _inner_panel(rows)
			var scroll: ScrollContainer = panel.get_child(0)
			var content: Control = scroll.get_child(0)
			check("40 rows stay inside the embed box",
				panel.get_global_rect().end.y <= rows.get_global_rect().end.y + 1.0)
			check("and the inner scroll actually scrolls",
				content.get_combined_minimum_size().y > scroll.size.y + 1.0)
			print("PASS" if not failed else "FAILED")
			quit(1 if failed else 0)
			return true
	return false
