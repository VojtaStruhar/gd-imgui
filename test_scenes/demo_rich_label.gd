extends Control
## Demonstrates: rich_label — a label with BBCode markup support.

@onready var g: ImGui = $Imgui

var bbcode := "[b]Bold[/b], [i]italic[/i], [color=orange]colored[/color], [wave]wavy[/wave]\nand [rainbow]rainbow[/rainbow] text."


func _process(_delta: float) -> void:
	g.begin_tool_panel()

	g.push_font_size(22)
	g.label("Demo: Rich label")
	g.pop_font_size()
	g.label("Edit the BBCode below — the rich label re-renders live:")
	g.next_min_width(420)
	bbcode = g.textedit(bbcode)
	g.separator()

	g.rich_label(bbcode)

	g.end_tool_panel()
