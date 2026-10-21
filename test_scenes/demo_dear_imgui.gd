extends Control
@onready var imgui: ImGui = $ImGui

var text_input: String
var float_input: float

func _process(_delta: float) -> void:
	imgui.label("Hello, world %d" % 123)
	if imgui.button("Save"):
		_my_save_function()
	text_input = imgui.textfield(text_input)
	float_input = imgui.slider_h(float_input, 0.0, 1.0, 0.01)

func _my_save_function() -> void:
	print("Save pressed!")
