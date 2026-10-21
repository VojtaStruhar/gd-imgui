extends SceneTree
## Headless checks for theme-chain detection (window title bar theming).
## Godot's theme inheritance only flows through Controls and Windows — a
## CanvasLayer in between cuts it — and merges every theme up the chain. The
## title bar must use the theme's "ImGuiWindowTitleBar" variation exactly when
## the engine will really deliver it, and our built-in style otherwise; never
## the engine's default panel style.
## Run: godot --headless --path . -s tests/test_theme_chain.gd

const THEME_COLOR := Color.HOT_PINK
const FALLBACK_COLOR := Color(0.12, 0.15, 0.22)

var frames := 0
var failed := false
var cases: Dictionary[String, ImGui] = {}


func check(name: String, condition: bool) -> void:
	if condition:
		print("  ok - ", name)
	else:
		failed = true
		print("FAIL - ", name)


func _titlebar_theme() -> Theme:
	var t := Theme.new()
	t.set_type_variation(&"ImGuiWindowTitleBar", &"PanelContainer")
	var style := StyleBoxFlat.new()
	style.bg_color = THEME_COLOR
	t.set_stylebox(&"panel", &"ImGuiWindowTitleBar", style)
	return t


func _add(name: String, build: Callable) -> void:
	var g := ImGui.new()
	build.call(g)
	cases[name] = g


func _initialize() -> void:
	_add("theme on a Control directly above", func(g: ImGui) -> void:
		var c := Control.new()
		c.theme = _titlebar_theme()
		root.add_child(c)
		c.add_child(g))
	_add("theme on the ImGui node itself, behind a CanvasLayer", func(g: ImGui) -> void:
		g.theme = _titlebar_theme()
		var layer := CanvasLayer.new()
		root.add_child(layer)
		layer.add_child(g))
	_add("theme above a CanvasLayer (never delivered)", func(g: ImGui) -> void:
		var c := Control.new()
		c.theme = _titlebar_theme()
		root.add_child(c)
		var layer := CanvasLayer.new()
		c.add_child(layer)
		layer.add_child(g))
	_add("outer theme defines it, nearer theme doesn't (themes merge)", func(g: ImGui) -> void:
		var outer := Control.new()
		outer.theme = _titlebar_theme()
		root.add_child(outer)
		var inner := Control.new()
		inner.theme = Theme.new()
		outer.add_child(inner)
		inner.add_child(g))


func _process(_delta: float) -> bool:
	frames += 1
	for g in cases.values():
		g.begin_window("t", true, false)
		g.label("x")
		g.end_window()
	if frames == 6:
		var expected: Dictionary[String, Color] = {
			"theme on a Control directly above": THEME_COLOR,
			"theme on the ImGui node itself, behind a CanvasLayer": THEME_COLOR,
			"theme above a CanvasLayer (never delivered)": FALLBACK_COLOR,
			"outer theme defines it, nearer theme doesn't (themes merge)": THEME_COLOR,
		}
		for name in cases:
			var bar: PanelContainer = cases[name].get_child(0).get_child(0).get_child(0)
			var style := bar.get_theme_stylebox(&"panel") as StyleBoxFlat
			check("%s -> %s" % [name, "theme's color" if expected[name] == THEME_COLOR else "built-in fallback"],
				style != null and style.bg_color == expected[name])
		print("PASS" if not failed else "FAILED")
		quit(1 if failed else 0)
		return true
	return false
