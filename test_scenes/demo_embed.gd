extends Control
## Demonstrates: embed — injecting your own node instance into the imgui tree.
## The instance is created once, configured by you, and only ever removed from
## the tree (never freed), so its internal state persists.

@onready var g: ImGui = $Imgui

var item_list := ItemList.new()
var show_embedded := true
var on_right := false


func _ready() -> void:
	item_list.custom_minimum_size = Vector2(260, 150)
	for i in 20:
		item_list.add_item("Persistent item %d" % i)


func _process(_delta: float) -> void:
	g.begin_tool_panel()

	g.push_font_size(22)
	g.label("Demo: Embedded nodes")
	g.pop_font_size()
	g.label("The ItemList below is created once in _ready() and injected\nwith embed(). Select an item, scroll around, then hide it or\nmove it — selection and scroll position survive, because the\nnode is only removed from the tree, never freed.")
	show_embedded = g.checkbox(show_embedded, "Show the embedded node")
	on_right = g.checkbox(on_right, "Put it in the right column")
	g.separator()

	g.begin_hbox()

	g.begin_vbox()
	g.label("Left column")
	if show_embedded and not on_right:
		g.embed(item_list)
	g.end_vbox()

	g.begin_vbox()
	g.label("Right column")
	if show_embedded and on_right:
		g.embed(item_list)
	g.end_vbox()

	g.end_hbox()

	g.end_tool_panel()
