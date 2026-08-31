extends Control
## Demonstrates the styling API: push_font_size / push_font_color /
## push_separation / next_tooltip — imperative styling for attributes that
## would otherwise need theme (variation) edits.

@onready var g: ImGui = $Imgui

var font_size := 24
var font_color := Color(1.0, 0.6, 0.3)
var separation := 16


func _process(_delta: float) -> void:
	g.begin_tool_panel()

	g.push_font_size(22)
	g.label("Demo: Styling")
	g.pop_font_size()
	g.separator()

	g.begin_grid(2)
	g.label("Font size")
	font_size = g.spinbox(font_size, 8, 48)
	g.label("Font color")
	font_color = g.color_picker(font_color)
	g.label("Separation")
	separation = g.spinbox(separation, 0, 48)
	g.end_grid()
	g.separator()

	g.push_font_size(font_size)
	g.push_font_color(font_color)
	g.label("Styled with push_font_size and push_font_color.")
	g.pop_font_color()
	g.pop_font_size()

	g.next_font_color(Color.RED)
	g.label("next_font_color styles one element only...")
	g.label("...so this one is back to normal.")
	g.next_variation(&"Label_Error")
	g.label("next_variation(\"Label_Error\") — one-shot theme variation.")

	g.label("push_separation spaces out any container:")
	g.push_separation(separation)
	g.begin_hbox()
	for i in 4:
		g.button("B%d" % i)
	g.end_hbox()
	g.pop_separation()
	g.separator()

	g.next_tooltip("Tooltips work on any widget.")
	g.button("Hover me for a tooltip")

	g.next_tooltip("Even labels, which normally ignore the mouse.")
	g.label("This label has a tooltip as well.")

	g.end_tool_panel()
