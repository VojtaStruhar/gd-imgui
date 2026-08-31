extends Control
## Demonstrates: embedding entire scenes — each with its own ImGui — inside
## another imgui, as tabs. Only the active tab's instance is in the tree; the
## others are detached (never freed) and their processing pauses, so every
## scene keeps its full state: fold states, colors, row counts, scroll…

@onready var g: ImGui = $Imgui

var foldables: Control
var picker: Control
var scroll_rows: Control


func _ready() -> void:
	foldables = _instantiate_demo("res://test_scenes/demo_foldable.tscn")
	picker = _instantiate_demo("res://test_scenes/demo_color_picker.tscn")
	scroll_rows = _instantiate_demo("res://test_scenes/demo_scroll_panel.tscn")


func _instantiate_demo(path: String) -> Control:
	var instance: Control = (load(path) as PackedScene).instantiate()
	# Embedded nodes size themselves, and a plain Control scene root has no
	# minimum size of its own.
	instance.custom_minimum_size = Vector2(640, 360)
	return instance


func _process(_delta: float) -> void:
	g.begin_vbox()
	g.next_font_size(22)
	g.label("Demo: Nested imgui scenes")
	g.label("Each tab embeds a whole demo scene running its own ImGui.\nInteract with one, switch tabs and come back — the instance\nleft the tree but was never freed, so it kept all its state.")

	g.begin_tabs()
	g.begin_margin(8)
	# No scroll containers needed out here: each embedded demo's own
	# begin_tool_panel scrolls within the rect the instance is given. (An
	# outer scroll couldn't work anyway — a plain Control scene root reports
	# no content-driven minimum size, so there'd be nothing to scroll by.)
	if g.tab("Foldables"):
		g.embed(foldables)
	if g.tab("Color picker"):
		g.embed(picker)
	if g.tab("Scroll panel"):
		g.embed(scroll_rows)
	g.end_margin()
	g.end_tabs()

	g.end_vbox()


func _exit_tree() -> void:
	# We own the instances: whichever is embedded right now dies with the
	# tree, the detached ones must be freed by hand.
	for instance in [foldables, picker, scroll_rows]:
		if instance != null and not instance.is_inside_tree():
			instance.queue_free()
