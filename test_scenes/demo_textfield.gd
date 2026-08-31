extends Control
## Demonstrates: textfield — single-line text input including the secret
## (password) mode — and textedit, the multiline variant.

@onready var g: ImGui = $Imgui

var username := "player1"
var password := "hunter2"
var show_password := false
var notes := "Multiline notes\ngo here."


func _process(_delta: float) -> void:
	g.begin_tool_panel()

	g.push_font_size(22)
	g.label("Demo: Text fields")
	g.pop_font_size()

	g.begin_grid(2)
	g.label("Username:")
	g.next_min_width(240)
	username = g.textfield(username)
	g.label("Password:")
	g.next_min_width(240)
	password = g.textfield(password, true, not show_password)
	g.end_grid()
	show_password = g.checkbox(show_password, "Show password")
	g.separator()

	g.label("Multiline (textedit):")
	notes = g.textedit(notes)

	g.end_tool_panel()
