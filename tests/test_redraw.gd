extends SceneTree
## Windowed check of the core efficiency promise: with a static UI, nothing
## redraws. Counts draw-signal emissions on every CanvasItem for 60 frames —
## stricter than the editor's Debug > Canvas Redraw overlay, since containers
## that paint nothing are counted too.
## Run: godot --path . -s tests/test_redraw.gd   (a window flashes briefly)

var frames := 0
var failed := false
var scene: Node
var counts := {}


func check(name: String, condition: bool) -> void:
	if condition:
		print("  ok - ", name)
	else:
		failed = true
		print("FAIL - ", name)


func _initialize() -> void:
	scene = (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(scene)


func _hook(n: Node) -> void:
	if n is CanvasItem:
		var p := n.get_path()
		counts[p] = 0
		n.draw.connect(func() -> void: counts[p] += 1)
	for c in n.get_children():
		_hook(c)


func _noisy() -> Array[String]:
	var result: Array[String] = []
	for k: NodePath in counts:
		if counts[k] >= 30:
			result.append(str(k))
	return result


func _process(_delta: float) -> bool:
	frames += 1
	match frames:
		10:
			_hook(root)
		70:
			# main.tscn: only the animating ProgressBar may redraw every frame.
			var noisy := _noisy()
			check("main.tscn: exactly one continuously-redrawing item", noisy.size() == 1)
			check("main.tscn: and it is the animating ProgressBar",
				noisy.size() == 1 and noisy[0].contains("ProgressBar"))
			if failed:
				for n in noisy:
					print("       redrawing: ", n)
			scene.queue_free()
			scene = (load("res://test_scenes/demo_scroll_panel.tscn") as PackedScene).instantiate()
			root.add_child(scene)
			counts.clear()
		80:
			_hook(root)
		140:
			var noisy := _noisy()
			check("static tool panel: zero continuously-redrawing items", noisy.is_empty())
			if failed:
				for n in noisy:
					print("       redrawing: ", n)
			print("PASS" if not failed else "FAILED")
			quit(1 if failed else 0)
			return true
	return false
