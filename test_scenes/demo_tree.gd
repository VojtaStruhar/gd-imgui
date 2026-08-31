extends Control
## Demonstrates: begin_tree_node — Dear-ImGui-style tree nodes: collapsible,
## indented and freely nestable.

@onready var g: ImGui = $Imgui


func _process(_delta: float) -> void:
	g.begin_tool_panel()
	g.push_font_size(22)
	g.label("Demo: Tree nodes")
	g.pop_font_size()
	g.label("Click a node title to expand it. Nodes nest freely.")
	g.separator()

	if g.begin_tree_node("World", false):
		if g.begin_tree_node("Environment"):
			g.label("DirectionalLight3D")
			g.label("WorldEnvironment")
			if g.button("Press me!"):
				print("Pressed a tree button!")
		g.end_tree_node()

		if g.begin_tree_node("Player"):
			g.label("Camera3D")
			if g.begin_tree_node("Inventory"):
				g.label("Sword")
				g.label("Potion (x3)")
			g.end_tree_node()
		g.end_tree_node()

		g.label("StaticBody3D (floor)")
	g.end_tree_node()

	g.end_tool_panel()
