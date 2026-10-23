extends SceneTree
## Headless checks for icons on buttons and dropdown options: applied on creation
## and on reuse, one per option (null = none), kept in step as the option list
## shrinks and grows, and cleared again once the caller stops passing them.
## Run: godot --headless --path . -s tests/test_icons.gd

var frames := 0
var failed := false
var g: ImGui
var red: Texture2D = PlaceholderTexture2D.new()
var blue: Texture2D = PlaceholderTexture2D.new()
var options: Array[String] = []
var icons: Array[Texture2D] = []
var button_icon: Texture2D = null


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


## Builds one frame with the given state, then checks what the nodes ended up with.
func step(name: String, opts: Array[String], ics: Array[Texture2D], btn: Texture2D, expect: Array) -> void:
	options = opts
	icons = ics
	button_icon = btn
	g.begin_vbox()
	g.button("b", true, button_icon)
	g.dropdown(0, options, icons)
	g.end_vbox()
	var button: Button = g.get_child(0).get_child(0)
	var dropdown: OptionButton = g.get_child(0).get_child(1)
	# Element-wise: Array == tells a null Object (what get_item_icon returns) from null.
	var same := dropdown.item_count == expect.size()
	for i in mini(dropdown.item_count, expect.size()):
		same = same and dropdown.get_item_icon(i) == expect[i]
	check(name + ": dropdown item icons", same)
	check(name + ": button icon", button.icon == btn)


func _process(_delta: float) -> bool:
	frames += 1
	match frames:
		1:
			step("created with icons", ["a", "b", "c"], [red, null, blue], red, [red, null, blue])
			var button: Button = g.get_child(0).get_child(0)
			var dropdown: OptionButton = g.get_child(0).get_child(1)
			check("icons fit the widget instead of stretching it", button.expand_icon and dropdown.expand_icon)
		2:
			step("reused, icons swapped", ["a", "b", "c"], [blue, red, null], blue, [blue, red, null])
		3:
			step("list shrinks", ["a", "b"], [blue, red], blue, [blue, red])
		4:
			step("icons dropped", ["a", "b"], [], null, [null, null])
		5:
			step("list grows back with icons", ["a", "b", "c"], [red, red, red], red, [red, red, red])
			print("PASS" if not failed else "FAILED")
			quit(1 if failed else 0)
			return true
	return false
