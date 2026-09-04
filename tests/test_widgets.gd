extends SceneTree
## Headless checks for core widget behavior: the fitted scroll clamps to the
## screen, windows close/reopen/drag, folded foldables drop their contents.
## Run: godot --headless --path . -s tests/test_widgets.gd

var frames := 0
var failed := false
var scene: Node


func check(name: String, condition: bool) -> void:
	if condition:
		print("  ok - ", name)
	else:
		failed = true
		print("FAIL - ", name)


func _initialize() -> void:
	scene = (load("res://test_scenes/demo_scroll_panel.tscn") as PackedScene).instantiate()
	root.add_child(scene)


func _tool_panel_vbox() -> Control:
	return scene.get_node("Imgui").get_child(0).get_child(0).get_child(0).get_child(0)


func _process(_delta: float) -> bool:
	frames += 1
	match frames:
		# --- Fitted scroll clamps to the screen ---
		2:
			scene.set("row_count", 200)
		12:
			var panel: Control = scene.get_node("Imgui").get_child(0)
			var scroll: ScrollContainer = panel.get_child(0)
			var content: Control = scroll.get_child(0)
			var viewport_h := scroll.get_viewport_rect().size.y
			check("scroll content overflows the screen", content.get_combined_minimum_size().y > viewport_h)
			check("scroll clamps to the screen", scroll.custom_minimum_size.y <= viewport_h and scroll.custom_minimum_size.y >= viewport_h - 10.0)
			check("panel stays on screen", panel.get_global_rect().end.y <= viewport_h + 1.0)
			scene.queue_free()
			scene = (load("res://test_scenes/demo_window.tscn") as PackedScene).instantiate()
			root.add_child(scene)

		# --- Windows: close, reopen, drag ---
		18:
			var g: Control = scene.get_node("Imgui")
			var win: PanelContainer = g.get_child(1)
			check("window is tagged and visible", win.has_meta("_imgui_window") and win.visible)
			var close: Button = win.get_child(0).get_child(0).get_child(0).get_child(1)
			check("close button shown for closable window", close.visible)
			close.pressed.emit()
		21:
			var win: PanelContainer = scene.get_node("Imgui").get_child(1)
			check("close hides the window", not win.visible)
			check("close reaches the caller's variable", scene.get("inspector_open") == false)
			scene.set("inspector_open", true)
		24:
			var g: Control = scene.get_node("Imgui")
			var win: PanelContainer = g.get_child(1)
			check("window reopens", win.visible)
			var press := InputEventMouseButton.new()
			press.button_index = MOUSE_BUTTON_LEFT
			press.pressed = true
			var before: Vector2 = win.position
			g._imgui_window_titlebar_input(press, win)
			var motion := InputEventMouseMotion.new()
			motion.relative = Vector2(30, 40)
			g._imgui_window_titlebar_input(motion, win)
			check("title bar drag moves the window", win.position - before == Vector2(30, 40))
			scene.queue_free()
			scene = (load("res://test_scenes/demo_foldable.tscn") as PackedScene).instantiate()
			root.add_child(scene)

		# --- Foldables: skipped contents are destroyed, fold state drives it ---
		30:
			var vbox := _tool_panel_vbox()
			var audio: FoldableContainer = vbox.get_child(3)
			var about: FoldableContainer = vbox.get_child(5)
			check("expanded foldable has contents", not audio.folded and audio.get_child(0).get_child_count() > 0)
			check("folded-by-default foldable is empty", about.folded and about.get_child(0).get_child_count() == 0)
			audio.folded = true
		34:
			var audio: FoldableContainer = _tool_panel_vbox().get_child(3)
			check("folding destroys skipped contents", audio.get_child(0).get_child_count() == 0)
			print("PASS" if not failed else "FAILED")
			quit(1 if failed else 0)
			return true
	return false
