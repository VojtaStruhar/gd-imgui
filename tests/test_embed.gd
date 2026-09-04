extends SceneTree
## Headless checks for embed(): user-owned nodes are removed but never freed,
## can move between slots, are never adopted by regular widgets, and are
## rescued out of imgui subtrees that get destroyed.
## Run: godot --headless --path . -s tests/test_embed.gd

var frames := 0
var failed := false
var g: ImGui
var mine := Label.new()
var phase := 0
var show := true
var slot_right := false


func check(name: String, condition: bool) -> void:
	if condition:
		print("  ok - ", name)
	else:
		failed = true
		print("FAIL - ", name)


func _initialize() -> void:
	var root_control := Control.new()
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(root_control)
	g = ImGui.new()
	root_control.add_child(g)
	mine.text = "user-owned"


func _build() -> void:
	match phase:
		0: # base layout: embed in one of two slots, or not at all
			g.begin_vbox()
			g.label("above")
			if show and not slot_right:
				g.embed(mine)
			g.label("below")
			if show and slot_right:
				g.embed(mine)
			g.end_vbox()
		1: # same slot now holds an imgui-created Label of the same type
			g.begin_vbox()
			g.label("above")
			g.label("imgui label")
			g.label("below")
			g.end_vbox()
		2: # embedded deep inside a nested vbox
			g.begin_vbox()
			g.begin_vbox()
			g.embed(mine)
			g.end_vbox()
			g.end_vbox()
		3: # inner container changes type -> old inner vbox is freed
			g.begin_vbox()
			g.begin_hbox()
			g.embed(mine)
			g.end_hbox()
			g.end_vbox()


func _process(_delta: float) -> bool:
	frames += 1
	_build()

	match frames:
		5:
			check("embedded at the call position", mine.get_index() == 1 and mine.get_parent() is VBoxContainer)
			show = false
		8:
			check("hidden: removed but not freed", is_instance_valid(mine) and mine.get_parent() == null)
			check("hidden: state intact", mine.text == "user-owned")
			show = true
		11:
			check("re-embedded at the same position", mine.get_index() == 1)
			slot_right = true
		14:
			check("moved to the other slot", mine.get_index() == 2)
			slot_right = false
			phase = 1
		17:
			var slot: Label = g.get_child(0).get_child(1)
			check("same-type widget does not adopt it", slot != mine and slot.text == "imgui label")
			check("survives being replaced", is_instance_valid(mine) and mine.get_parent() == null and mine.text == "user-owned")
			phase = 2
		20:
			check("embedded inside a nested container", mine.get_parent() is VBoxContainer)
			phase = 3
		23:
			check("rescued when its imgui ancestor is freed", is_instance_valid(mine) and mine.get_parent() is HBoxContainer and mine.text == "user-owned")
			print("PASS" if not failed else "FAILED")
			quit(1 if failed else 0)
			return true
	return false
