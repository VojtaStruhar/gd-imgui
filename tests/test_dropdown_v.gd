extends SceneTree
## Headless checks for dropdown_v(): every item property (text, icon, id,
## disabled, separator) reaches the popup, missing keys fall back to defaults,
## items switch between plain and separator in place, the list shrinks and
## grows, a user pick beats the caller's index for one frame, and an unchanged
## list writes nothing to the popup.
## Run: godot --headless --path . -s tests/test_dropdown_v.gd

var frames := 0
var failed := false
var g: ImGui
var red: Texture2D = PlaceholderTexture2D.new()
var blue: Texture2D = PlaceholderTexture2D.new()
var list_a: Array[Dictionary] = [
	{ "text": "Fire", "icon": red },
	{ "separator": true },
	{ "text": "Water", "id": 42, "disabled": true },
	{ "separator": true, "text": "Section" },
	{ "text": "Earth" },
]
var list_b: Array[Dictionary] = [
	{ "text": "A" },
	{ "separator": true },
	{ "text": "C" },
	{ "text": "D" },
]
var node: OptionButton
var popup_changes := 0
var result := 0


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


## One frame: a vbox holding the dropdown and a label that follows it.
func step(selected: int, items: Array[Dictionary], enabled: bool = true) -> void:
	g.begin_vbox()
	result = g.dropdown_v(selected, items, enabled)
	g.label("after")
	g.end_vbox()


func ob() -> OptionButton:
	return g.get_child(0).get_child(0)


## [text, icon, id, disabled, separator] per item.
func items_match(expect: Array) -> bool:
	var o := ob()
	if o.item_count != expect.size():
		print("    item count is ", o.item_count)
		return false
	for i in expect.size():
		var e: Array = expect[i]
		var actual := [o.get_item_text(i), o.get_item_icon(i), o.get_item_id(i), o.is_item_disabled(i), o.is_item_separator(i)]
		# Element-wise: Array == tells a null Object (what get_item_icon returns) from null.
		var same := true
		for k in e.size():
			same = same and actual[k] == e[k]
		if not same:
			print("    item ", i, " is ", actual)
			return false
	return true


func _process(_delta: float) -> bool:
	frames += 1
	match frames:
		1:
			step(4, list_a)
			node = ob()
			check("created: every property applied", items_match([
				["Fire", red, 0, false, false],
				["", null, 1, false, true],
				["Water", null, 42, true, false],
				["Section", null, 3, false, true],
				["Earth", null, 4, false, false],
			]))
			check("created: selected index returned and shown", result == 4 and node.selected == 4 and node.text == "Earth")
			check("created: takes exactly one slot", g.get_child(0).get_child_count() == 2 and g.get_child(0).get_child(1) is Label)
			check("created: icon fits the widget", node.expand_icon)
			node.get_popup().menu_changed.connect(func() -> void: popup_changes += 1)
		2, 3:
			step(4, list_a)
			check("unchanged frame %d: node reused" % frames, ob() == node)
			check("unchanged frame %d: popup untouched" % frames, popup_changes == 0)
		4:
			# Literal passed straight in; every kind flips and every default returns.
			step(4, [
				{ "separator": true, "text": "Top" },
				{ "text": "Mid", "icon": blue, "id": 7 },
				{ "text": "Water" },
				{ "text": "Section" },
				{ "text": "Earth", "disabled": true },
			])
			check("reused: properties updated in place, stale ones cleared", items_match([
				["Top", null, 0, false, true],
				["Mid", blue, 7, false, false],
				["Water", null, 2, false, false],
				["Section", null, 3, false, false],
				["Earth", null, 4, true, false],
			]))
			check("reused: same node, selection kept", ob() == node and result == 4)
			check("reused: changes reached the popup", popup_changes > 0)
		5:
			step(1, [{ "text": "A" }, { "text": "B" }])
			check("shrunk", items_match([["A", null, 0, false, false], ["B", null, 1, false, false]]))
			check("shrunk: selection follows the caller", result == 1 and node.selected == 1)
		6:
			step(3, list_b)
			check("grown: new items start from defaults", items_match([
				["A", null, 0, false, false],
				["", null, 1, false, true],
				["C", null, 2, false, false],
				["D", null, 3, false, false],
			]))
			check("grown: selection follows the caller", result == 3)
		7:
			# The user picks index 2 while the caller still says 3.
			ob().select(2)
			ob().item_selected.emit(2)
			step(3, list_b)
			check("pick: user choice wins over the caller's index", result == 2)
		8:
			step(3, list_b)
			check("pick consumed: the caller's index applies again", result == 3)
		9:
			step(-1, list_b, false)
			check("-1 selects nothing", result == -1 and ob().text == "")
			check("enabled = false disables the button", ob().disabled)
		10:
			step(0, list_b)
			check("enabled again", not ob().disabled and result == 0)
		11:
			# A label takes the dropdown's slot, so the next one is built from scratch.
			g.begin_vbox()
			g.label("not a dropdown")
			g.end_vbox()
		12:
			# Fresh dropdown that starts empty while the caller already has a selection.
			step(2, [])
			check("fresh empty list: nothing selected", ob() != node and result == -1)
		13:
			step(2, [{ "text": "x" }, { "text": "y" }, { "text": "z" }])
			# Growing through item_count would leave the pick without its check mark.
			check("list arriving later: selection, face text and check mark land",
				result == 2 and ob().text == "z" and ob().get_popup().is_item_checked(2))
			print("PASS" if not failed else "FAILED")
			quit(1 if failed else 0)
			return true
	return false
