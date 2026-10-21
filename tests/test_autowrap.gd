extends SceneTree
## Headless checks for the autowrap styling API (next_/push_/pop_ autowrap_mode):
## one-shot vs stack, precedence, each label type's engine default when nothing is
## set, a reused node going back to that default once its push is gone, and that
## unconsumed one-shots / unpopped pushes don't leak into later frames.
## Run: godot --headless --path . -s tests/test_autowrap.gd

const OFF := TextServer.AUTOWRAP_OFF
const ARBITRARY := TextServer.AUTOWRAP_ARBITRARY
const WORD := TextServer.AUTOWRAP_WORD
const SMART := TextServer.AUTOWRAP_WORD_SMART

var frames := 0
var failed := false
var g: ImGui
var pushing := true # dropped after frame 3: the same nodes must fall back to their defaults


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


func _build() -> void:
	g.label("probe") # root level: the first styled element of every frame, reveals leaks
	g.begin_vbox()
	g.label("plain") # 0
	g.rich_label("plain") # 1
	g.next_autowrap_mode(WORD)
	g.label("next") # 2
	g.label("after next") # 3: the one-shot was consumed
	g.push_autowrap_mode(ARBITRARY)
	g.label("pushed") # 4
	g.rich_label("pushed") # 5
	g.next_autowrap_mode(OFF)
	g.rich_label("next beats push") # 6
	g.pop_autowrap_mode()
	g.label("popped") # 7
	g.rich_label("popped") # 8
	g.next_autowrap_mode(WORD)
	g.button("eats it") # 9: can't wrap, but any element consumes the one-shot
	g.label("after button") # 10
	if pushing:
		g.push_autowrap_mode(WORD)
	g.label("dropped push") # 11
	g.rich_label("dropped push") # 12
	if pushing:
		g.pop_autowrap_mode()
	g.end_vbox()


func _process(_delta: float) -> bool:
	frames += 1
	pushing = frames <= 3
	_build()
	if frames == 2:
		# Deliberately left dangling: must not leak into later frames.
		g.next_autowrap_mode(WORD)
		g.push_autowrap_mode(WORD)
	if frames == 3:
		# The probe is the first styled element after the dangling calls of frame 2:
		# a leaked one-shot or push would show on it now (and be gone by frame 5).
		check("dangling one-shots/pushes don't leak into the next frame",
			(g.get_child(0) as Label).autowrap_mode == OFF)
		var vbox: VBoxContainer = g.get_child(1)
		check("push applies to a Label", vbox.get_child(11).autowrap_mode == WORD)
		check("...and to a RichTextLabel", vbox.get_child(12).autowrap_mode == WORD)
	if frames == 5:
		var vbox: VBoxContainer = g.get_child(1)
		var mode_of := func(i: int) -> int: return vbox.get_child(i).autowrap_mode
		check("unstyled Label keeps the engine default (off)", mode_of.call(0) == OFF)
		check("unstyled RichTextLabel keeps the engine default (smart)", mode_of.call(1) == SMART)
		check("next_autowrap_mode applies to the next label", mode_of.call(2) == WORD)
		check("next_* applies to one element", mode_of.call(3) == OFF)
		check("push_autowrap_mode applies to a Label", mode_of.call(4) == ARBITRARY)
		check("...and to a RichTextLabel", mode_of.call(5) == ARBITRARY)
		check("next_* beats the pushed mode", mode_of.call(6) == OFF)
		check("pop_autowrap_mode restores each type's default", mode_of.call(7) == OFF and mode_of.call(8) == SMART)
		check("any element consumes a one-shot, even one that can't wrap",
			(vbox.get_child(9) as Button).autowrap_mode == OFF and mode_of.call(10) == OFF)
		check("a reused Label goes back to its default once the push is gone", mode_of.call(11) == OFF)
		check("...and so does a reused RichTextLabel", mode_of.call(12) == SMART)
		print("PASS" if not failed else "FAILED")
		quit(1 if failed else 0)
		return true
	return false
