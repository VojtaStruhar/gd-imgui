extends ImGui

var frame_number: int = 0

var showing_advanced := true

func _ready() -> void:
	super()
	

func _process(delta: float) -> void:
	super(delta)
	frame_number += 1
	begin_tabs()
	
	if tab("Game"):
		begin_vbox()
		label("Imgui in Godot!")
		
		if button("Press me"):
			print("Action 1!")
			label("Press!")
		
		
		separator_h()
		begin_hbox()
		label("This button toggles an entire tab:")
		if button("Hide advanced" if showing_advanced else "Show advanced"):
			showing_advanced = !showing_advanced
			
		end_hbox()
		end_vbox()
		
	if showing_advanced:
		if tab("Game - advanced"):
			begin_grid(2)
			label("Frame number:")
			label(str(frame_number))
			label("OS Name:")
			label(OS.get_name())
			end_grid()
	
	if tab("Other"):
		label("Some junk here")
	
	end_tabs()
