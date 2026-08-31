extends Control
## Demonstrates: texture_rect — its stretch modes in particular.

@onready var g: ImGui = $Imgui

const ICON: Texture2D = preload("res://icon.svg")
## Order matches TextureRect.StretchMode values.
const MODE_NAMES: Array[String] = [
	"Scale",
	"Tile",
	"Keep",
	"Keep Centered",
	"Keep Aspect",
	"Keep Aspect Centered",
	"Keep Aspect Covered",
]

var mode: int = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
var ignore_size := false


func _process(_delta: float) -> void:
	g.begin_tool_panel()

	g.push_font_size(22)
	g.label("Demo: Texture stretch modes")
	g.pop_font_size()
	g.begin_grid(2)
	g.label("Stretch mode:")
	mode = g.dropdown(mode, MODE_NAMES)
	g.end_grid()
	ignore_size = g.checkbox(ignore_size, "Ignore texture size (texture can shrink below its native size)")
	g.separator()

	g.label("The texture below is stretched into a 400x200 area:")
	g.next_min_size(400, 200)
	var expand := TextureRect.EXPAND_IGNORE_SIZE if ignore_size else TextureRect.EXPAND_KEEP_SIZE
	g.texture_rect(ICON, mode as TextureRect.StretchMode, expand)

	g.end_tool_panel()
