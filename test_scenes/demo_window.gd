extends Control
## Demonstrates: begin_window — floating windows with a draggable title bar and
## an optional close button. Windows never leave the screen.

@onready var g: ImGui = $Imgui

var inspector_open := true
var log_open := true
var health := 75.0
var log_lines := 4


func _process(_delta: float) -> void:
	g.begin_tool_panel()
	g.push_font_size(22)
	g.label("Demo: Draggable windows")
	g.pop_font_size()
	g.label("Drag the windows by their title bar. Close them with the\n× button, reopen them with the checkboxes below.")
	inspector_open = g.checkbox(inspector_open, "Inspector window")
	log_open = g.checkbox(log_open, "Log window")
	g.end_tool_panel()

	inspector_open = g.begin_window("Inspector", inspector_open, true, Vector2(420, 60))
	if inspector_open:
		g.begin_grid(2)
		g.label("Health:")
		health = g.spinboxf(health, 0, 100)
		g.label("Position:")
		g.label("(3, 1, 4)")
		g.end_grid()
	g.end_window()

	log_open = g.begin_window("Log", log_open, true, Vector2(450, 260))
	if log_open:
		if g.button("Log a line"):
			log_lines += 1
		for i in log_lines:
			g.label("[%02d] something happened" % i)
	g.end_window()
