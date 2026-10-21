extends SceneTree
## Headless checks for the max-size styling API (next_/push_/pop_ max_size and
## propagate_max_size): one-shot vs stack, precedence, negative = unbounded, and
## that unconsumed one-shots / unpopped pushes don't leak into later frames.
## Run: godot --headless --path . -s tests/test_max_size.gd

const NONE := Vector2(-1, -1)

var frames := 0
var failed := false
var g: ImGui


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
	g.begin_vbox() # the first styled element of every frame: reveals leaks
	g.label("plain") # 0
	g.next_max_width(100)
	g.label("next") # 1
	g.label("after next") # 2: the one-shot was consumed
	g.push_max_size(50, 60)
	g.label("pushed") # 3
	g.next_max_height(10)
	g.label("next beats push") # 4: replaces the pushed size on both axes
	g.pop_max_size()
	g.label("popped") # 5
	g.next_max_size(-37, 5)
	g.label("negative") # 6: negative axis is unbounded
	g.next_propagate_max_size()
	g.begin_hbox() # 7
	g.label("kid") # 7/0: the one-shot went to the hbox only
	g.end_hbox()
	g.push_propagate_max_size()
	g.label("pushed propagate") # 8
	g.pop_propagate_max_size()
	g.label("not propagating") # 9
	g.end_vbox()


func _process(_delta: float) -> bool:
	frames += 1
	_build()
	if frames == 2:
		# Deliberately left dangling: must not leak into later frames.
		g.next_max_width(77)
		g.next_propagate_max_size()
		g.push_max_size(1, 1)
		g.push_propagate_max_size()
	if frames == 5:
		var vbox: VBoxContainer = g.get_child(0)
		var max_of := func(i: int) -> Vector2: return (vbox.get_child(i) as Control).custom_maximum_size
		var propagates := func(i: int) -> bool: return (vbox.get_child(i) as Control).propagate_maximum_size
		check("unstyled element is unbounded", max_of.call(0) == NONE)
		check("next_max_width bounds width only", max_of.call(1) == Vector2(100, -1))
		check("next_* applies to one element", max_of.call(2) == NONE)
		check("push_max_size applies until popped", max_of.call(3) == Vector2(50, 60))
		check("next_* replaces the pushed size", max_of.call(4) == Vector2(-1, 10))
		check("pop_max_size restores unbounded", max_of.call(5) == NONE)
		check("negative axes are unbounded", max_of.call(6) == Vector2(-1, 5))
		check("next_propagate_max_size reaches the container", propagates.call(7))
		check("...but not its children", not (vbox.get_child(7).get_child(0) as Control).propagate_maximum_size)
		check("push_propagate_max_size applies until popped", propagates.call(8))
		check("popped propagate is off again", not propagates.call(9))
		check("dangling one-shots/pushes don't leak into later frames",
			vbox.custom_maximum_size == NONE and not vbox.propagate_maximum_size)
		print("PASS" if not failed else "FAILED")
		quit(1 if failed else 0)
		return true
	return false
