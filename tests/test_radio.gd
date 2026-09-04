extends SceneTree
## Headless checks for radio(): exclusive selection via a real ButtonGroup, a
## click updating the result, external (programmatic) changes correctly
## unpressing every other option, and the options list resizing.
## Run: godot --headless --path . -s tests/test_radio.gd

var frames := 0
var failed := false
var g: ImGui
var selected := 0
var options: Array[String] = ["Low", "Medium", "High"]
var last_result := 0


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


func _hbox() -> HBoxContainer:
	return g.get_child(0)


func _process(_delta: float) -> bool:
	frames += 1
	last_result = g.radio(selected, options)
	selected = last_result

	match frames:
		2:
			var hbox := _hbox()
			check("creates one CheckBox per option", hbox.get_child_count() == options.size())
			check("options share one ButtonGroup", (hbox.get_child(0) as CheckBox).button_group == (hbox.get_child(1) as CheckBox).button_group)
			check("initial selection is pressed", (hbox.get_child(0) as CheckBox).button_pressed)
			check("others are not", not (hbox.get_child(1) as CheckBox).button_pressed and not (hbox.get_child(2) as CheckBox).button_pressed)
			# Simulate a real user click on option 2 ("High").
			(_hbox().get_child(2) as CheckBox).set_pressed(true)
		4:
			check("click is reflected in the return value", last_result == 2)
			var hbox := _hbox()
			check("only the clicked option is pressed", (hbox.get_child(2) as CheckBox).button_pressed
				and not (hbox.get_child(0) as CheckBox).button_pressed
				and not (hbox.get_child(1) as CheckBox).button_pressed)
			# External (programmatic) change, not a click.
			selected = 0
		6:
			var hbox := _hbox()
			check("external change unpresses every other option",
				(hbox.get_child(0) as CheckBox).button_pressed
				and not (hbox.get_child(1) as CheckBox).button_pressed
				and not (hbox.get_child(2) as CheckBox).button_pressed)
			options = ["Low", "High"]
			selected = 0
		8:
			check("shrinking the options list removes the extra CheckBox", _hbox().get_child_count() == 2)
			print("PASS" if not failed else "FAILED")
			quit(1 if failed else 0)
			return true
	return false
