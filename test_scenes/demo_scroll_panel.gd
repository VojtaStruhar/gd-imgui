extends Control
## Demonstrates: begin_tool_panel / begin_scroll_v — a tool panel wrapped in a
## fitted scroll container: it grows with its content, but stops at the bottom
## of the screen and scrolls instead of overflowing.

@onready var g: ImGui = $Imgui

var row_count := 8
var row_values: Array[float] = []


func _process(_delta: float) -> void:
	g.begin_tool_panel()

	g.push_font_size(22)
	g.label("Demo: Scrollable tool panel")
	g.pop_font_size()
	g.label("The panel grows with its content. Once it reaches the\nbottom of the screen it stops growing and scrolls instead.")
	g.separator()

	g.begin_hbox()
	if g.button("Add row"):
		row_count += 1
	if g.button("Remove row", row_count > 0):
		row_count = max(row_count - 1, 0)
	g.end_hbox()
	g.label("Rows: %d" % row_count)
	g.separator()

	# The buttons above change row_count mid-frame, so size the backing array
	# after them, right before it's indexed.
	while row_values.size() < row_count:
		row_values.append(50.0)

	for i in row_count:
		g.begin_hbox()
		g.next_min_width(80)
		g.label("Row %d" % i)
		g.push_alignment_h(SizeFlags.SIZE_EXPAND_FILL)
		row_values[i] = g.slider_h(row_values[i], 0, 100)
		g.pop_alignment_h()
		g.end_hbox()

	g.end_tool_panel()
