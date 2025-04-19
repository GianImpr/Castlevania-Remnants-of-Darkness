@tool
extends RichTextLabel
signal clicked()

var _formatter:GUIDEInputFormatter = GUIDEInputFormatter.new(64)

var input:GUIDEInput:
	set(value):
		if value == input:
			return
		
		if is_instance_valid(input):
			input.changed.disconnect(_refresh)
		
		input = value
		
		if is_instance_valid(input):
			input.changed.connect(_refresh)

		_refresh()

func _refresh():
	if not is_instance_valid(input):
		parse_bbcode("[center][i]<not bound>[/i][/center]")
		tooltip_text = ""
		return
		
	var text := await _formatter.input_as_richtext_async(input, false)
	parse_bbcode("[center]" + text + "[/center]")
	tooltip_text = _formatter.input_as_text(input)

 
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit()


	
