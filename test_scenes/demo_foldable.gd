extends Control
## Demonstrates: begin_foldable — collapsible sections with a clickable title.
## The fold state lives on the node, so it survives across frames untouched.

@onready var g: ImGui = $Imgui

var master_volume := 80.0
var music_volume := 60.0
var fullscreen := false
var vsync := true
var quality := 1

const QUALITY_OPTIONS: Array[String] = ["Low", "Medium", "High"]


func _process(_delta: float) -> void:
	g.begin_tool_panel()
	g.push_font_size(22)
	g.label("Demo: Foldable sections")
	g.pop_font_size()
	g.label("Click a section title to collapse or expand it.")
	g.separator()

	if g.begin_foldable("Audio"):
		g.begin_grid(2)
		g.label("Master")
		master_volume = g.slider_h(master_volume, 0, 100)
		g.label("Music")
		music_volume = g.slider_h(music_volume, 0, 100)
		g.end_grid()
	g.end_foldable()

	if g.begin_foldable("Video"):
		fullscreen = g.checkbox(fullscreen, "Fullscreen")
		vsync = g.checkbox(vsync, "V-Sync")
		quality = g.dropdown(quality, QUALITY_OPTIONS)
	g.end_foldable()

	if g.begin_foldable("About", true):
		g.label("This section starts folded.")
		g.rich_label("[i]Skipping the contents while folded is fine —\njust always call end_foldable().[/i]")
	g.end_foldable()

	g.end_tool_panel()
