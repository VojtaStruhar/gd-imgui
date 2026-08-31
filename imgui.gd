class_name ImGui
extends Container

var __parent: Control = self
var __inputs: Dictionary[NodePath, Dictionary] = { }
# Call depth
var __cursor: Array[int] = [0]
var __theme_variations_stack: Array[String] = []
# Applies minimum size to ALL elements, until popped.
var __min_size_stack: Array[Vector2] = []
var __next_min_size_stack: Array[Vector2] = []
var __alignment_horizontal_stack: Array[SizeFlags] = []
var __alignment_vertical_stack: Array[SizeFlags] = []
var __font_size_stack: Array[int] = []
var __font_color_stack: Array[Color] = []
var __separation_stack: Array[int] = []
var __next_variation: String = ""
var __next_font_size: int = -1
var __next_font_color: Variant = null # Color, or null when unset
var __next_separation: int = -1
var __next_alignment_h: int = -1
var __next_alignment_v: int = -1
var __next_tooltip: String = ""
var __next_anchors_preset: int = -1


@export_group("Defaults", "_default")
@export var _default_slider_v_height: float = 50
@export var _default_slider_h_width: float = 50

func _ready() -> void:
	for child in get_children():
		push_warning("IMGUI - removing initial children")
		remove_child(child)
		child.queue_free()


func _process(_delta: float) -> void:
	assert(__cursor.size() == 1)
	__cursor[0] = 0
	if not __theme_variations_stack.is_empty():
		push_warning("Leftover theme variations in the stack: " + str(__theme_variations_stack))
		__theme_variations_stack.clear()
	if not __font_size_stack.is_empty():
		push_warning("Leftover font sizes in the stack: " + str(__font_size_stack))
		__font_size_stack.clear()
	if not __font_color_stack.is_empty():
		push_warning("Leftover font colors in the stack: " + str(__font_color_stack))
		__font_color_stack.clear()
	if not __separation_stack.is_empty():
		push_warning("Leftover separations in the stack: " + str(__separation_stack))
		__separation_stack.clear()
	__next_variation = ""
	__next_font_size = -1
	__next_font_color = null
	__next_separation = -1
	__next_alignment_h = -1
	__next_alignment_v = -1
	__next_tooltip = ""
	__next_anchors_preset = -1

## All future [Control]s created with this ImGui will receive this 
## [member Control.theme_type_variation] until it is popped with [method ImGui.pop_variation].
func push_variation(theme_variation: String) -> void:
	__theme_variations_stack.append(theme_variation)

func pop_variation(count: int = 1) -> void:
	assert(count >= 1)
	for i in count:
		assert(not __theme_variations_stack.is_empty(), "Attempted to pop empty stack")
		__theme_variations_stack.pop_back()

## [member Control.theme_type_variation] for only the [i]next[/i] element.
## Takes precedence over [method push_variation].
func next_variation(theme_variation: String) -> void:
	__next_variation = theme_variation

func push_alignment_h(align: SizeFlags) -> void:
	__alignment_horizontal_stack.append(align)


func pop_alignment_h(count: int = 1) -> void:
	assert(count >= 1)
	for i in count:
		assert(not __alignment_horizontal_stack.is_empty(), "Attempted to pop empty stack")
		__alignment_horizontal_stack.pop_back()

## [member Control.size_flags_horizontal] for only the [i]next[/i] element.
func next_alignment_h(align: SizeFlags) -> void:
	__next_alignment_h = align

func push_alignment_v(align: SizeFlags) -> void:
	__alignment_vertical_stack.append(align)

func pop_alignment_v(count: int = 1) -> void:
	assert(count >= 1)
	for i in count:
		assert(not __alignment_vertical_stack.is_empty(), "Attempted to pop empty stack")
		__alignment_vertical_stack.pop_back()

## [member Control.size_flags_vertical] for only the [i]next[/i] element.
func next_alignment_v(align: SizeFlags) -> void:
	__next_alignment_v = align

## Set minimum size of the [i]next[/i] element that will be created. Also see [method ImGui.push_min_size].
func next_min_size(min_width: float, min_height: float) -> void:
	__next_min_size_stack.append(Vector2(min_width, min_height))

## Convenience method for [method ImGui.next_min_size]
func next_min_height(min_height: float) -> void:
	next_min_size(0, min_height)

## Convenience method for [method ImGui.next_min_size]
func next_min_width(min_width: float) -> void:
	next_min_size(min_width, 0)

## All future [Control]s created with this ImGui will get [param min_size] assigned to
## [member Control.custom_minimum_size] until it is popped with [method ImGui.pop_minimum_size].
func push_min_size(min_width: float, min_height: float) -> void:
	__min_size_stack.append(Vector2(min_width, min_height))

## Convenience method for [method ImGui.push_min_size]
func push_min_height(min_height: float) -> void:
	push_min_size(0, min_height)

## Convenience method for [method ImGui.push_min_size]
func push_min_width(min_width: float) -> void:
	push_min_size(min_width, 0)

func pop_minimum_size(count: int = 1) -> void:
	assert(count >= 1)
	for i in count:
		assert(not __min_size_stack.is_empty(), "Attempted to pop empty stack")
		__min_size_stack.pop_back()


## All future [Control]s render text at [param font_size] until popped with
## [method pop_font_size]. Theme overrides don't propagate to internal children,
## so composite widgets (e.g. [SpinBox]) keep their theme font size.
func push_font_size(font_size: int) -> void:
	__font_size_stack.append(font_size)


func pop_font_size(count: int = 1) -> void:
	assert(count >= 1)
	for i in count:
		assert(not __font_size_stack.is_empty(), "Attempted to pop empty stack")
		__font_size_stack.pop_back()


## Font size for only the [i]next[/i] element. Takes precedence over
## [method push_font_size].
func next_font_size(font_size: int) -> void:
	assert(font_size > 0)
	__next_font_size = font_size


## All future [Control]s render text in [param color] until popped with
## [method pop_font_color].
func push_font_color(color: Color) -> void:
	__font_color_stack.append(color)


func pop_font_color(count: int = 1) -> void:
	assert(count >= 1)
	for i in count:
		assert(not __font_color_stack.is_empty(), "Attempted to pop empty stack")
		__font_color_stack.pop_back()


## Font color for only the [i]next[/i] element. Takes precedence over
## [method push_font_color].
func next_font_color(color: Color) -> void:
	__next_font_color = color


## All future containers (box, flow, grid, split) space their children
## [param separation] pixels apart until popped with [method pop_separation].
func push_separation(separation: int) -> void:
	assert(separation >= 0)
	__separation_stack.append(separation)


func pop_separation(count: int = 1) -> void:
	assert(count >= 1)
	for i in count:
		assert(not __separation_stack.is_empty(), "Attempted to pop empty stack")
		__separation_stack.pop_back()


## Child separation for only the [i]next[/i] container. Takes precedence over
## [method push_separation].
func next_separation(separation: int) -> void:
	assert(separation >= 0)
	__next_separation = separation


## Tooltip shown when hovering the [i]next[/i] element. Like all imgui calls,
## it must be repeated every frame, right before the widget it belongs to.
func next_tooltip(text: String) -> void:
	__next_tooltip = text


## Positions and sizes the [i]next[/i] element like the given anchors preset
## would (e.g. [constant Control.PRESET_FULL_RECT] to fill the screen,
## [constant Control.PRESET_TOP_RIGHT] to dock a panel to a corner). Only
## meaningful for top-level elements — direct children of the ImGui node —
## since containers lay out their children themselves.
func next_anchors_preset(preset: Control.LayoutPreset) -> void:
	__next_anchors_preset = preset


func begin_tabs() -> void:
	next_separation(0)
	begin_vbox()
	# TODO: Refactor styling
	if __parent.custom_minimum_size.is_zero_approx():
		__parent.custom_minimum_size.x = 400
	if __parent.anchor_right != 1.0:
		__parent.set_anchors_preset(Control.PRESET_FULL_RECT)
	if __parent.alignment != BoxContainer.ALIGNMENT_BEGIN:
		__parent.alignment = BoxContainer.ALIGNMENT_BEGIN

	var current := _get_current_node()
	if current is not TabBar:
		_destroy_rest_of_this_layout_level()
		var tb := TabBar.new()
		__parent.add_child(tb)
		current = tb
	
	_apply_styling(current)
	__cursor[__cursor.size() - 1] += 1 # Next node

	begin_panel()
	__parent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	__parent.set_meta(&"_imgui_tab_bar", true)
	__parent.set_meta(&"_imgui_tab_visited", -1)


func tab(tab_name: String) -> bool:
	var tab_container := __parent
	while tab_container.get_class() != &"PanelContainer" or !tab_container.has_meta(&"_imgui_tab_bar"):
		tab_container = tab_container.get_parent()
		assert(tab_container != get_tree().root, "Unclosed `begin_tabs`")

	var tab_bar: TabBar = tab_container.get_parent().get_child(0)
	assert(tab_bar)
	var index: int = tab_container.get_meta(&"_imgui_tab_visited")
	index += 1
	if tab_bar.tab_count <= index:
		tab_bar.add_tab(tab_name)
	else:
		if not tab_bar.get_tab_title(index) == tab_name:
			while tab_bar.tab_count > index:
				tab_bar.remove_tab(tab_bar.tab_count - 1)
			tab_bar.add_tab(tab_name)

	tab_container.set_meta(&"_imgui_tab_visited", index)

	return tab_bar.get_tab_title(tab_bar.current_tab) == tab_name


func end_tabs() -> void:
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()
	assert(__parent is PanelContainer)
	end_panel()
	if __parent.get_child_count() != (__cursor[__cursor.size() - 1] + 1): # +1 for the TabBar?
		_destroy_rest_of_this_layout_level()
	assert(__parent is VBoxContainer)
	end_vbox()


func progress_bar(value: float, max_val: float, show_percentage: bool = true) -> void:
	var current := _get_current_node()
	if current is not ProgressBar:
		_destroy_rest_of_this_layout_level()
		var pb := ProgressBar.new()
		__parent.add_child(pb)
		current = pb

	_apply_styling(current)
	current.min_value = 0
	current.max_value = max_val
	current.value = value
	current.show_percentage = show_percentage

	__cursor[__cursor.size() - 1] += 1 # Next node


func toggle(on: bool, text: String = "", enabled: bool = true) -> bool:
	var current := _get_current_node()
	if current is not CheckButton:
		_destroy_rest_of_this_layout_level()
		var check := CheckButton.new()
		check.text = text
		check.name = str(__cursor).validate_node_name()
		check.toggled.connect(_register_button_toggle.bind(check))
		__parent.add_child(check)
		current = check

	_apply_styling(current)
	current.disabled = !enabled
	var np := self.get_path_to(current)
	if not __inputs.erase(np):
		current.set_pressed_no_signal(on)
	
	__cursor[__cursor.size() - 1] += 1 # Next node

	return current.button_pressed


func checkbox(on: bool, text: String = "") -> bool:
	var current := _get_current_node()
	if current is not CheckBox:
		_destroy_rest_of_this_layout_level()
		var check := CheckBox.new()
		check.text = text
		check.name = str(__cursor).validate_node_name()
		check.toggled.connect(_register_button_toggle.bind(check))
		__parent.add_child(check)
		current = check

	_apply_styling(current)
	var np := self.get_path_to(current)
	if not __inputs.erase(np):
		current.set_pressed_no_signal(on)
		
		
	__cursor[__cursor.size() - 1] += 1 # Next node

	return current.button_pressed


func label(text: String, alignment: HorizontalAlignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT) -> void:
	var current := _get_current_node()
	if current is not Label:
		_destroy_rest_of_this_layout_level()
		var l := Label.new()
		l.name = str(__cursor).validate_node_name()
		l.text = text
		__parent.add_child(l)
		current = l

	_apply_styling(current)
	current.horizontal_alignment = alignment
	current.text = text
	__cursor[__cursor.size() - 1] += 1 # Next node

## Displays a texture. [param expand] controls how the texture contributes to
## the element's minimum size — [constant TextureRect.EXPAND_IGNORE_SIZE] lets
## it shrink below the texture's native size, so the layout (or
## [method next_min_size]) fully controls the footprint.
func texture_rect(texture: Texture2D, stretch: TextureRect.StretchMode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED, expand: TextureRect.ExpandMode = TextureRect.EXPAND_KEEP_SIZE) -> void:
	var current := _get_current_node()
	if current is not TextureRect:
		_destroy_rest_of_this_layout_level()
		var trect := TextureRect.new()
		trect.name = str(__cursor).validate_node_name()
		__parent.add_child(trect)
		current = trect

	_apply_styling(current)
	current.texture = texture
	if current.stretch_mode != stretch:
		current.stretch_mode = stretch
	if current.expand_mode != expand:
		current.expand_mode = expand

	__cursor[__cursor.size() - 1] += 1 # Next node


## Solid-colored rectangle. It has no size of its own — give it one with
## [method next_min_size], or let the layout stretch it.
func color_rect(color: Color) -> void:
	var current := _get_current_node()
	if current is not ColorRect:
		_destroy_rest_of_this_layout_level()
		var crect := ColorRect.new()
		crect.name = str(__cursor).validate_node_name()
		__parent.add_child(crect)
		current = crect

	_apply_styling(current)
	current.color = color

	__cursor[__cursor.size() - 1] += 1 # Next node


## Multiline label with BBCode markup support, e.g.
## [code]"[b]bold[/b] [color=red]red[/color]"[/code].
func rich_label(bbcode: String) -> void:
	var current := _get_current_node()
	if current is not RichTextLabel:
		_destroy_rest_of_this_layout_level()
		var rtl := RichTextLabel.new()
		rtl.name = str(__cursor).validate_node_name()
		rtl.bbcode_enabled = true
		rtl.fit_content = true
		rtl.scroll_active = false
		__parent.add_child(rtl)
		current = rtl

	_apply_styling(current)
	# Assigning text re-parses the whole BBCode document, so only do it on change.
	if current.text != bbcode:
		current.text = bbcode

	__cursor[__cursor.size() - 1] += 1 # Next node

func separator() -> void:
	match __parent.get_class():
		&"HBoxContainer", &"HFlowContainer":
			separator_v()
		&"VBoxContainer", &"VFlowContainer":
			separator_h()
		_:
			breakpoint

func separator_v() -> void:
	var current := _get_current_node()
	if current is not VSeparator:
		_destroy_rest_of_this_layout_level()
		var vs := VSeparator.new()
		vs.name = str(__cursor).validate_node_name()
		__parent.add_child(vs)
		current = vs

	_apply_styling(current)
	__cursor[__cursor.size() - 1] += 1 # Next node


func separator_h() -> void:
	var current := _get_current_node()
	if current is not HSeparator:
		_destroy_rest_of_this_layout_level()
		var hs := HSeparator.new()
		hs.name = str(__cursor).validate_node_name()
		__parent.add_child(hs)
		current = hs

	_apply_styling(current)
	__cursor[__cursor.size() - 1] += 1 # Next node


func button(text: String, enabled: bool = true) -> bool:
	var current := _get_current_node()
	if current == null or current.get_class() != "Button":
		_destroy_rest_of_this_layout_level()
		var b := Button.new()
		b.name = str(__cursor).validate_node_name()
		b.pressed.connect(_register_button_press.bind(b))
		__parent.add_child(b)
		current = b

	_apply_styling(current)
	current.disabled = !enabled
	current.text = text
	var np := self.get_path_to(current)

	__cursor[__cursor.size() - 1] += 1 # Next node
	return __inputs.erase(np)


## Single line text input. With [param secret] enabled the text is masked,
## password-style — toggle it at will to show/hide the text.
func textfield(text: String, enabled: bool = true, secret: bool = false) -> String:
	var current := _get_current_node()
	if current is not LineEdit:
		_destroy_rest_of_this_layout_level()
		var le := LineEdit.new()
		le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		le.name = str(__cursor).validate_node_name()
		le.text_changed.connect(_register_textfield_input.bind(le))
		__parent.add_child(le)
		current = le

	_apply_styling(current)
	current.editable = enabled
	if current.secret != secret:
		current.secret = secret
	var np := self.get_path_to(current)
	if __inputs.has(np):
		__inputs.erase(np)
	else:
		# Setting text on a focused line edit messes with cursor
		# Also unnecessary text updates cause re-renders
		if not current.has_focus() and current.text != text: 
			current.text = text
	
	__cursor[__cursor.size() - 1] += 1 # Next node
	
	return current.text

## Multiline text field
func textedit(text: String, enabled: bool = true) -> String:
	var current := _get_current_node()
	if current is not TextEdit:
		_destroy_rest_of_this_layout_level()
		var te := TextEdit.new()
		te.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		te.custom_minimum_size.y = 100
		te.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		te.backspace_deletes_composite_character_enabled = true
		te.scroll_fit_content_height = true
		te.name = str(__cursor).validate_node_name()
		te.text_changed.connect(_register_textedit_input.bind(te))
		__parent.add_child(te)
		current = te

	_apply_styling(current)
	current.editable = enabled
	var np := self.get_path_to(current)
	if __inputs.has(np):
		__inputs.erase(np)
	else:
		# Setting text on a focused line edit messes with cursor
		# Also unnecessary text updates cause re-renders
		if not current.has_focus() and current.text != text: 
			current.text = text
	
	__cursor[__cursor.size() - 1] += 1 # Next node
	
	return current.text


func dropdown(selected_index: int, options: Array[String], enabled: bool = true) -> int:
	var current := _get_current_node()
	if current is not OptionButton:
		_destroy_rest_of_this_layout_level()
		var ob := OptionButton.new()
		ob.name = str(__cursor).validate_node_name()
		ob.item_selected.connect(func(_i: int) -> void: _register_dropdown_select(ob))
		__parent.add_child(ob)
		current = ob

	for i: int in range(options.size()):
		var text = options[i]
		if i < current.item_count:
			current.set_item_text(i, text)
		else:
			current.add_item(text)
	while current.item_count > options.size():
		current.remove_item(current.item_count - 1)

	_apply_styling(current)
	current.disabled = !enabled

	var np := self.get_path_to(current)
	if not __inputs.erase(np): # Means that there is no input
		(current as OptionButton).selected = selected_index

	__cursor[__cursor.size() - 1] += 1 # Next node

	return current.selected


## Compact color input ([ColorPickerButton]). Returns the current color.
func color_picker(color: Color, edit_alpha: bool = true, enabled: bool = true) -> Color:
	var current := _get_current_node()
	if current is not ColorPickerButton:
		_destroy_rest_of_this_layout_level()
		var cpb := ColorPickerButton.new()
		cpb.name = str(__cursor).validate_node_name()
		cpb.color_changed.connect(_register_color_change.bind(cpb))
		__parent.add_child(cpb)
		current = cpb

	_apply_styling(current)
	current.disabled = !enabled
	if current.edit_alpha != edit_alpha:
		current.edit_alpha = edit_alpha

	var np := self.get_path_to(current)
	if not __inputs.erase(np): # Means that there is no input
		if current.color != color:
			current.color = color

	__cursor[__cursor.size() - 1] += 1 # Next node

	return current.color
	
	
func spinbox(value: int, min_val: int, max_val: int, step: int = 1, enabled: bool = true) -> int:
	var current := _get_current_node()
	if current is not SpinBox:
		_destroy_rest_of_this_layout_level()
		var sb := SpinBox.new()
		sb.name = str(__cursor).validate_node_name()
		# Configure the range before connecting — setting min/max clamps the
		# value and would register the resulting signal as user input.
		sb.min_value = min_val
		sb.max_value = max_val
		sb.step = step
		sb.set_value_no_signal(value)
		sb.value_changed.connect(_register_spinbox_change.bind(sb))
		__parent.add_child(sb)
		current = sb

	_apply_styling(current)
	# SpinBox setters don't all early-out on identical values, so only write on
	# change — otherwise the node redraws every frame.
	if current.editable != enabled:
		current.editable = enabled
	if current.min_value != min_val:
		current.min_value = min_val
	if current.max_value != max_val:
		current.max_value = max_val
	if current.step != step:
		current.step = step

	var np := self.get_path_to(current)
	if not __inputs.erase(np): # Means that there is no input
		if current.value != value:
			current.set_value_no_signal(value)

	__cursor[__cursor.size() - 1] += 1 # Next node

	return current.value

func spinboxf(value: float, min_val: float, max_val: float, step: float = 0.01, enabled: bool = true) -> float:
	var current := _get_current_node()
	if current is not SpinBox:
		_destroy_rest_of_this_layout_level()
		var sb := SpinBox.new()
		sb.name = str(__cursor).validate_node_name()
		# Configure the range before connecting — setting min/max clamps the
		# value and would register the resulting signal as user input.
		sb.min_value = min_val
		sb.max_value = max_val
		sb.step = step
		sb.set_value_no_signal(value)
		sb.value_changed.connect(_register_spinbox_change.bind(sb))
		__parent.add_child(sb)
		current = sb

	_apply_styling(current)
	# SpinBox setters don't all early-out on identical values, so only write on
	# change — otherwise the node redraws every frame.
	if current.editable != enabled:
		current.editable = enabled
	if current.min_value != min_val:
		current.min_value = min_val
	if current.max_value != max_val:
		current.max_value = max_val
	if current.step != step:
		current.step = step

	var np := self.get_path_to(current)
	if not __inputs.erase(np): # Means that there is no input
		if current.value != value:
			current.set_value_no_signal(value)

	__cursor[__cursor.size() - 1] += 1 # Next node

	return current.value

func slider_h(value: float, min_val: float, max_val: float, step: float = 0.1, enabled: bool = true) -> float:
	var current := _get_current_node()
	if current is not HSlider:
		_destroy_rest_of_this_layout_level()
		var hs := HSlider.new()
		hs.custom_minimum_size.x = _default_slider_h_width
		hs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hs.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hs.name = str(__cursor).validate_node_name()
		# Configure the range before connecting — setting min/max clamps the
		# value and would register the resulting signal as user input.
		hs.min_value = min_val
		hs.max_value = max_val
		hs.step = step
		hs.set_value_no_signal(value)
		hs.value_changed.connect(_register_spinbox_change.bind(hs))
		__parent.add_child(hs)
		current = hs

	var enforce_minimum_height: bool = __min_size_stack.is_empty() or (__min_size_stack.back().x < _default_slider_h_width)
	if enforce_minimum_height: push_min_width(_default_slider_h_width)
	_apply_styling(current)
	if enforce_minimum_height: pop_minimum_size()

	if current.editable != enabled:
		current.editable = enabled
	if current.min_value != min_val:
		current.min_value = min_val
	if current.max_value != max_val:
		current.max_value = max_val
	if current.step != step:
		current.step = step
	var np := self.get_path_to(current)
	var target_value: float = __inputs.get(np, {}).get("value", value)
	if current.value != target_value:
		current.set_value_no_signal(target_value)
	if __inputs.has(np): __inputs.erase(np)

	__cursor[__cursor.size() - 1] += 1 # Next node

	return current.value

##
func slider_v(value: float, min_val: float, max_val: float, step: float = 1, enabled: bool = true) -> float:
	var current := _get_current_node()
	if current is not VSlider:
		_destroy_rest_of_this_layout_level()
		var vs := VSlider.new()
		vs.custom_minimum_size.y = _default_slider_v_height
		vs.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		vs.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vs.name = str(__cursor).validate_node_name()
		# Configure the range before connecting — setting min/max clamps the
		# value and would register the resulting signal as user input.
		vs.min_value = min_val
		vs.max_value = max_val
		vs.step = step
		vs.set_value_no_signal(value)
		vs.value_changed.connect(_register_spinbox_change.bind(vs))
		__parent.add_child(vs)
		current = vs

	var enforce_minimum_height: bool = __min_size_stack.is_empty() or (__min_size_stack.back().y < _default_slider_v_height)
	if enforce_minimum_height: push_min_height(_default_slider_v_height)
	_apply_styling(current)
	if enforce_minimum_height: pop_minimum_size()
	
	current.editable = enabled
	current.min_value = min_val
	current.max_value = max_val
	current.step = step
	
	var np := self.get_path_to(current)
	current.set_value_no_signal(__inputs.get(np, {}).get("value", value))
	if __inputs.has(np): __inputs.erase(np)

	__cursor[__cursor.size() - 1] += 1 # Next node

	return current.value


func begin_vbox() -> void:
	var current := _get_current_node()
	if current is not VBoxContainer:
		_destroy_rest_of_this_layout_level()
		var vbox := VBoxContainer.new()
		vbox.name = str(__cursor).validate_node_name()
		__parent.add_child(vbox)
		current = vbox

	_apply_styling(current)
	__parent = current
	__cursor.append(0)


func end_vbox() -> void:
	assert(__parent is VBoxContainer)
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1


func begin_margin(margin: int = -1) -> void:
	begin_margin_v(Vector4i.ONE * margin)

func begin_margin_v(margin: Vector4i) -> void:
	var current := _get_current_node()
	if current is not MarginContainer:
		_destroy_rest_of_this_layout_level()
		var mc := MarginContainer.new()
		mc.name = str(__cursor).validate_node_name()
		__parent.add_child(mc)
		current = mc
	
	_apply_styling(current)

	_set_constant_override(current, &"margin_left", margin.x)
	_set_constant_override(current, &"margin_top", margin.y)
	_set_constant_override(current, &"margin_right", margin.z)
	_set_constant_override(current, &"margin_bottom", margin.w)

	__parent = current
	__cursor.append(0)


func end_margin() -> void:
	assert(__parent is MarginContainer)
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1



func begin_hbox() -> void:
	var current := _get_current_node()
	if current is not HBoxContainer:
		_destroy_rest_of_this_layout_level()
		var vbox := HBoxContainer.new()
		vbox.name = str(__cursor).validate_node_name()
		__parent.add_child(vbox)
		current = vbox
	
	_apply_styling(current)
	__parent = current
	__cursor.append(0)


func end_hbox() -> void:
	assert(__parent is HBoxContainer)
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1


## Like [method begin_hbox], but children wrap to a new row when they run out
## of horizontal space.
func begin_hflow() -> void:
	var current := _get_current_node()
	if current is not HFlowContainer:
		_destroy_rest_of_this_layout_level()
		var flow := HFlowContainer.new()
		flow.name = str(__cursor).validate_node_name()
		__parent.add_child(flow)
		current = flow

	_apply_styling(current)
	__parent = current
	__cursor.append(0)


func end_hflow() -> void:
	assert(__parent is HFlowContainer)
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1


## Like [method begin_vbox], but children wrap to a new column when they run
## out of vertical space.
func begin_vflow() -> void:
	var current := _get_current_node()
	if current is not VFlowContainer:
		_destroy_rest_of_this_layout_level()
		var flow := VFlowContainer.new()
		flow.name = str(__cursor).validate_node_name()
		__parent.add_child(flow)
		current = flow

	_apply_styling(current)
	__parent = current
	__cursor.append(0)


func end_vflow() -> void:
	assert(__parent is VFlowContainer)
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1

## Vertical scroll area that fits its content: it grows with the content until
## it would leave the bottom of the screen (or exceed [param max_height]), then
## stops growing and scrolls instead. Wrap tool panels in this so they never
## overflow the window. Also see [method begin_tool_panel].
## [br][br]
## Note: [ScrollContainer] only stretches its child across the scroll area when
## the child expands — call [code]next_alignment_h(SIZE_EXPAND_FILL)[/code]
## before the inner container if the content should fill a wider panel.
func begin_scroll_v(min_height: float = 0.0, max_height: float = -1.0) -> void:
	var current := _get_current_node()
	if current is not ScrollContainer:
		_destroy_rest_of_this_layout_level()
		var scroll := ScrollContainer.new()
		scroll.name = str(__cursor).validate_node_name()
		__parent.add_child(scroll)
		current = scroll

	if current.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_RESERVE:
		current.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_RESERVE
	if current.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
		current.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_apply_styling(current)

	# Content height is measured from the previous frame's children, so the fit
	# lags one frame behind content changes.
	var content_height := 0.0
	for child in current.get_children():
		if child is Control:
			if child.visible:
				content_height = maxf(content_height, child.get_combined_minimum_size().y)

	var available := get_viewport_rect().size.y - current.get_global_rect().position.y
	if __parent is PanelContainer:
		available -= __parent.get_theme_stylebox(&"panel").get_margin(SIDE_BOTTOM)
	if max_height >= 0.0:
		available = minf(available, max_height)
	current.custom_minimum_size.y = clampf(content_height, min_height, maxf(available, min_height))

	__parent = current
	__cursor.append(0)


## The recommended root for tool UIs: a panel wrapped in a fitted vertical
## scroll area ([method begin_scroll_v]), with a margin and a vbox inside. The
## panel grows with its content but never scrolls off screen. Must be closed
## with [method end_tool_panel].
func begin_tool_panel(margin: int = 8) -> void:
	begin_panel()
	begin_scroll_v()
	# ScrollContainer only stretches its child across the scroll area when the
	# child expands, which matters when the panel is wider than its content.
	next_alignment_h(SIZE_EXPAND_FILL)
	begin_margin(margin)
	begin_vbox()


func end_tool_panel() -> void:
	end_vbox()
	end_margin()
	end_scroll()
	end_panel()

func begin_scroll(vertical: ScrollContainer.ScrollMode = ScrollContainer.ScrollMode.SCROLL_MODE_RESERVE, horizontal: ScrollContainer.ScrollMode = ScrollContainer.ScrollMode.SCROLL_MODE_MAXIMIZE_FIRST) -> void:
	var current := _get_current_node()
	if current is not ScrollContainer:
		_destroy_rest_of_this_layout_level()
		var scroll := ScrollContainer.new()
		scroll.name = str(__cursor).validate_node_name()
		__parent.add_child(scroll)
		current = scroll
	
	current.horizontal_scroll_mode = horizontal
	current.vertical_scroll_mode = vertical
	_apply_styling(current)
	__parent = current
	__cursor.append(0)


func end_scroll() -> void:
	assert(__parent is ScrollContainer)
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1


func begin_panel() -> void:
	var current := _get_current_node()
	if current is not PanelContainer:
		_destroy_rest_of_this_layout_level()
		var grid := PanelContainer.new()
		grid.name = str(__cursor).validate_node_name()
		__parent.add_child(grid)
		current = grid

	_apply_styling(current)
	__parent = current
	__cursor.append(0)


func end_panel() -> void:
	assert(__parent is PanelContainer)
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1


func begin_grid(columns: int) -> void:
	var current := _get_current_node()
	if current is not GridContainer:
		_destroy_rest_of_this_layout_level()
		var grid := GridContainer.new()
		grid.name = str(__cursor).validate_node_name()
		__parent.add_child(grid)
		current = grid

	_apply_styling(current)
	current.columns = columns
	__parent = current
	__cursor.append(0)


func end_grid() -> void:
	assert(__parent is GridContainer)
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1


## Collapsible section with a clickable title. Children are laid out vertically
## and hidden while folded. Returns [code]true[/code] while expanded, so the
## contents may be skipped while folded — but [method end_foldable] must always
## be called. The fold state lives in the node; clicks toggle it automatically.
func begin_foldable(title: String, default_folded: bool = false) -> bool:
	var current := _get_current_node()
	if current is not FoldableContainer:
		_destroy_rest_of_this_layout_level()
		var foldable := FoldableContainer.new()
		foldable.name = str(__cursor).validate_node_name()
		foldable.folded = default_folded
		__parent.add_child(foldable)
		current = foldable

	_apply_styling(current)
	if current.title != title:
		current.title = title
	var expanded: bool = not current.folded
	__parent = current
	__cursor.append(0)
	# FoldableContainer stacks its children on top of each other like
	# PanelContainer, so the contents go into an internal vbox.
	begin_vbox()
	return expanded


func end_foldable() -> void:
	end_vbox()
	assert(__parent is FoldableContainer)
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1


## Dear-ImGui-style tree node: a foldable with indented content, meant to be
## nested. Returns [code]true[/code] while expanded — the contents may be
## skipped while folded, but [method end_tree_node] must always be called.
func begin_tree_node(label: String, default_folded: bool = true) -> bool:
	var expanded := begin_foldable(label, default_folded)
	begin_margin_v(Vector4i(16, 0, 0, 0))
	begin_vbox()
	return expanded


func end_tree_node() -> void:
	end_vbox()
	end_margin()
	end_foldable()


## Two panes side by side with a draggable divider. Expects exactly two
## children — put a container in each pane. The divider position is kept where
## the user dragged it.
func begin_hsplit(initial_offset: int = 0) -> void:
	var current := _get_current_node()
	if current is not HSplitContainer:
		_destroy_rest_of_this_layout_level()
		var split := HSplitContainer.new()
		split.name = str(__cursor).validate_node_name()
		split.split_offset = initial_offset
		__parent.add_child(split)
		current = split

	_apply_styling(current)
	__parent = current
	__cursor.append(0)


func end_hsplit() -> void:
	assert(__parent is HSplitContainer)
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1


## Vertical variant of [method begin_hsplit]: two panes stacked on top of each
## other with a draggable divider.
func begin_vsplit(initial_offset: int = 0) -> void:
	var current := _get_current_node()
	if current is not VSplitContainer:
		_destroy_rest_of_this_layout_level()
		var split := VSplitContainer.new()
		split.name = str(__cursor).validate_node_name()
		split.split_offset = initial_offset
		__parent.add_child(split)
		current = split

	_apply_styling(current)
	__parent = current
	__cursor.append(0)


func end_vsplit() -> void:
	assert(__parent is VSplitContainer)
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1


## Keeps its child at the given width:height [param ratio] regardless of the
## space the container gets. The container itself has no size of its own —
## give it one with [method next_min_size] (the child is fitted, centered,
## inside that area).
func begin_aspect_ratio(ratio: float = 1.0, stretch_mode: AspectRatioContainer.StretchMode = AspectRatioContainer.STRETCH_FIT) -> void:
	var current := _get_current_node()
	if current is not AspectRatioContainer:
		_destroy_rest_of_this_layout_level()
		var arc := AspectRatioContainer.new()
		arc.name = str(__cursor).validate_node_name()
		__parent.add_child(arc)
		current = arc

	_apply_styling(current)
	if current.ratio != ratio:
		current.ratio = ratio
	if current.stretch_mode != stretch_mode:
		current.stretch_mode = stretch_mode
	__parent = current
	__cursor.append(0)


func end_aspect_ratio() -> void:
	assert(__parent is AspectRatioContainer)
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1


## Floating window with a title bar the user can drag around. Must be called at
## the top level (not inside another container); it is kept within the screen.
## Like every widget, windows are identified by call position, so keep the call
## order stable. Later windows draw on top of earlier ones.
##
## Returns [code]true[/code] while the window is open. Feed the returned value
## back in as [param open], otherwise the close button has no lasting effect:
## [codeblock]
## win_open = g.begin_window("Tools", win_open, true)
## if win_open:
##     g.label("...")
## g.end_window()
## [/codeblock]
func begin_window(title: String, open: bool = true, closable: bool = false, initial_position: Vector2 = Vector2(48, 48)) -> bool:
	assert(__parent == self, "begin_window() must be top-level — it cannot be nested in other containers")

	var current := _get_current_node()
	if current is not PanelContainer or not current.has_meta(&"_imgui_window"):
		_destroy_rest_of_this_layout_level()
		var win := PanelContainer.new()
		win.name = str(__cursor).validate_node_name()
		win.set_meta(&"_imgui_window", true)
		win.position = initial_position
		__parent.add_child(win)
		current = win

	_apply_styling(current)

	var np := self.get_path_to(current)
	var is_open := open
	if __inputs.erase(np): # The close button was pressed
		is_open = false
	current.visible = is_open

	var viewport_size := get_viewport_rect().size
	current.global_position = current.global_position.clamp(Vector2.ZERO, (viewport_size - current.size).max(Vector2.ZERO))

	__parent = current
	__cursor.append(0)

	next_separation(0)
	begin_vbox()

	var title_bar := _get_current_node()
	if title_bar is not PanelContainer or not title_bar.has_meta(&"_imgui_window_titlebar"):
		_destroy_rest_of_this_layout_level()
		title_bar = _build_window_titlebar(current)
		__parent.add_child(title_bar)
	var title_row: HBoxContainer = title_bar.get_child(0)
	(title_row.get_child(0) as Label).text = title
	(title_row.get_child(1) as Button).visible = closable
	__cursor[__cursor.size() - 1] += 1 # Next node

	begin_margin(6)
	begin_vbox()

	return is_open


func end_window() -> void:
	end_vbox()
	end_margin()
	end_vbox()
	assert(__parent is PanelContainer and __parent.has_meta(&"_imgui_window"), "end_window() without matching begin_window()")
	if __parent.get_child_count() != __cursor[__cursor.size() - 1]:
		_destroy_rest_of_this_layout_level()

	__parent = __parent.get_parent()
	__cursor.pop_back()
	__cursor[__cursor.size() - 1] += 1

# -------------------- UTILITIES -------------------- #

func _register_button_press(b: Button) -> void:
	__inputs[self.get_path_to(b)] = { }

func _register_button_toggle(new_value: bool, b: BaseButton) -> void:
	__inputs[self.get_path_to(b)] = { "value": new_value }

func _register_textfield_input(new_text: String, le: LineEdit) -> void:
	__inputs[self.get_path_to(le)] = { "value": new_text }

func _register_textedit_input(te: TextEdit) -> void:
	__inputs[self.get_path_to(te)] = { "value": te.text }

func _register_dropdown_select(ob: OptionButton) -> void:
	__inputs[self.get_path_to(ob)] = { "value": ob.selected }

func _register_spinbox_change(new_value: float, origin: Control) -> void:
	__inputs[self.get_path_to(origin)] = { "value": new_value }


func _register_color_change(new_color: Color, origin: Control) -> void:
	__inputs[self.get_path_to(origin)] = { "value": new_color }


func _register_window_close(window: PanelContainer) -> void:
	__inputs[self.get_path_to(window)] = { "value": false }


func _build_window_titlebar(window: PanelContainer) -> PanelContainer:
	var bar := PanelContainer.new()
	bar.name = &"TitleBar"
	bar.set_meta(&"_imgui_window_titlebar", true)
	bar.mouse_default_cursor_shape = Control.CURSOR_MOVE
	bar.gui_input.connect(_imgui_window_titlebar_input.bind(window))
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.15, 0.22)
	style.set_content_margin_all(4)
	style.content_margin_left = 8
	bar.add_theme_stylebox_override(&"panel", style)

	var row := HBoxContainer.new()
	var title_label := Label.new()
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title_label)
	var close_button := Button.new()
	close_button.text = "×"
	close_button.flat = true
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.pressed.connect(_register_window_close.bind(window))
	row.add_child(close_button)
	bar.add_child(row)
	return bar


func _imgui_window_titlebar_input(event: InputEvent, window: PanelContainer) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			window.set_meta(&"_imgui_window_dragging", event.pressed)
	elif event is InputEventMouseMotion:
		if window.get_meta(&"_imgui_window_dragging", false):
			window.position += event.relative


func _get_current_node() -> Control:
	var c: Control = self
	for i in __cursor:
		if c.get_child_count() > i:
			c = c.get_child(i)
		else:
			return null
	return c


func _destroy_rest_of_this_layout_level() -> void:
	if __cursor.is_empty():
		# This only happens with the very first container?
		return

	var incorrect_one := _get_current_node()
	if incorrect_one == null:
		# The node isn't created yet
		return

	var p := incorrect_one.get_parent()
	while p.get_child_count() > __cursor[__cursor.size() - 1]:
		var child := p.get_child(-1)
		p.remove_child(child)
		child.queue_free()

func _apply_styling(element: Control) -> void:
	if __next_variation != "":
		element.theme_type_variation = __next_variation
		__next_variation = ""
	else:
		element.theme_type_variation = "" if __theme_variations_stack.is_empty() else __theme_variations_stack.back()

	if not __next_min_size_stack.is_empty():
		element.custom_minimum_size = __next_min_size_stack.pop_back()
	else:
		element.custom_minimum_size = Vector2.ZERO if __min_size_stack.is_empty() else __min_size_stack.back()

	if __next_alignment_h >= 0:
		element.size_flags_horizontal = __next_alignment_h
		__next_alignment_h = -1
	else:
		element.size_flags_horizontal = Control.SIZE_FILL if __alignment_horizontal_stack.is_empty() else __alignment_horizontal_stack.back()
	if __next_alignment_v >= 0:
		element.size_flags_vertical = __next_alignment_v
		__next_alignment_v = -1
	else:
		element.size_flags_vertical = Control.SIZE_FILL if __alignment_vertical_stack.is_empty() else __alignment_vertical_stack.back()

	# All theme override writes below only touch the node on an actual change:
	# add/remove_theme_*_override queue a redraw unconditionally, and reused
	# nodes must not redraw while nothing changes.
	var font_size := -1
	if __next_font_size > 0:
		font_size = __next_font_size
		__next_font_size = -1
	elif not __font_size_stack.is_empty():
		font_size = __font_size_stack.back()
	if font_size < 0:
		if element.has_theme_font_size_override(&"font_size"):
			element.remove_theme_font_size_override(&"font_size")
	elif not element.has_theme_font_size_override(&"font_size") or element.get_theme_font_size(&"font_size") != font_size:
		element.add_theme_font_size_override(&"font_size", font_size)

	var font_color: Variant = __next_font_color
	__next_font_color = null
	if font_color == null and not __font_color_stack.is_empty():
		font_color = __font_color_stack.back()
	if font_color == null:
		if element.has_theme_color_override(&"font_color"):
			element.remove_theme_color_override(&"font_color")
		if element is RichTextLabel and element.has_theme_color_override(&"default_color"):
			element.remove_theme_color_override(&"default_color")
	else:
		if not element.has_theme_color_override(&"font_color") or element.get_theme_color(&"font_color") != font_color:
			element.add_theme_color_override(&"font_color", font_color)
		if element is RichTextLabel and (not element.has_theme_color_override(&"default_color") or element.get_theme_color(&"default_color") != font_color):
			element.add_theme_color_override(&"default_color", font_color)

	var separation := -1
	if __next_separation >= 0:
		separation = __next_separation
		__next_separation = -1
	elif not __separation_stack.is_empty():
		separation = __separation_stack.back()
	if element is BoxContainer or element is SplitContainer:
		_set_constant_override(element, &"separation", separation)
	elif element is GridContainer or element is FlowContainer:
		_set_constant_override(element, &"h_separation", separation)
		_set_constant_override(element, &"v_separation", separation)

	if element.tooltip_text != __next_tooltip:
		element.tooltip_text = __next_tooltip
	if __next_tooltip != "" and element.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		# Labels and similar ignore the mouse by default, which suppresses tooltips.
		element.mouse_filter = Control.MOUSE_FILTER_PASS
	__next_tooltip = ""

	if __next_anchors_preset >= 0:
		_apply_anchors_preset(element, __next_anchors_preset as Control.LayoutPreset)
		__next_anchors_preset = -1


## Adds or removes a theme constant override ([param value] < 0 removes),
## touching the node only on an actual change — override writes queue a redraw
## unconditionally.
func _set_constant_override(element: Control, constant: StringName, value: int) -> void:
	if value < 0:
		if element.has_theme_constant_override(constant):
			element.remove_theme_constant_override(constant)
	elif not element.has_theme_constant_override(constant) or element.get_theme_constant(constant) != value:
		element.add_theme_constant_override(constant, value)


## Anchors don't survive on children of a Container (which the ImGui root is),
## so presets are emulated by writing the rect directly — re-applied every
## frame like everything else.
func _apply_anchors_preset(element: Control, preset: Control.LayoutPreset) -> void:
	var area: Vector2 = (element.get_parent() as Control).size
	var min_size := element.get_combined_minimum_size()
	match preset:
		Control.PRESET_FULL_RECT:
			element.position = Vector2.ZERO
			element.size = area
		Control.PRESET_LEFT_WIDE:
			element.position = Vector2.ZERO
			element.size = Vector2(min_size.x, area.y)
		Control.PRESET_RIGHT_WIDE:
			element.position = Vector2(area.x - min_size.x, 0)
			element.size = Vector2(min_size.x, area.y)
		Control.PRESET_TOP_WIDE:
			element.position = Vector2.ZERO
			element.size = Vector2(area.x, min_size.y)
		Control.PRESET_BOTTOM_WIDE:
			element.position = Vector2(0, area.y - min_size.y)
			element.size = Vector2(area.x, min_size.y)
		Control.PRESET_VCENTER_WIDE:
			element.position = Vector2((area.x - min_size.x) / 2.0, 0)
			element.size = Vector2(min_size.x, area.y)
		Control.PRESET_HCENTER_WIDE:
			element.position = Vector2(0, (area.y - min_size.y) / 2.0)
			element.size = Vector2(area.x, min_size.y)
		_:
			var factor := Vector2.ZERO
			match preset:
				Control.PRESET_TOP_LEFT: factor = Vector2(0, 0)
				Control.PRESET_TOP_RIGHT: factor = Vector2(1, 0)
				Control.PRESET_BOTTOM_LEFT: factor = Vector2(0, 1)
				Control.PRESET_BOTTOM_RIGHT: factor = Vector2(1, 1)
				Control.PRESET_CENTER_LEFT: factor = Vector2(0, 0.5)
				Control.PRESET_CENTER_TOP: factor = Vector2(0.5, 0)
				Control.PRESET_CENTER_RIGHT: factor = Vector2(1, 0.5)
				Control.PRESET_CENTER_BOTTOM: factor = Vector2(0.5, 1)
				Control.PRESET_CENTER: factor = Vector2(0.5, 0.5)
			element.size = min_size
			element.position = (area - min_size) * factor
