@tool
extends LineEdit

var sync: bool

var value: Variant:
	set(r):
		value = r
		
		if value == null:
			if not sync:
				text = ""
			tooltip_text = """<null>
Possible input:
Variant constructor (Color(1, 0, 0), "string", Vector2(), etc.)
@property name on the Object
$metadata name on the Object
%parameter name on the TweenAnimation
"""
		else:
			if not sync:
				text = var_to_str(value)
				if value is String:
					if value.begins_with("@") or value.begins_with("$") or value.begins_with("%"):
						text = value
			
			tooltip_text = str(value)
			if value is String:
				if value.begins_with("@"):
					tooltip_text = "Object Property: \"%s\"" % value.substr(1)
				elif value.begins_with("$"):
					tooltip_text = "Object Metadata: \"%s\"" % value.substr(1)
				elif value.begins_with("%"):
					tooltip_text = "TweenAnimation Parameter: \"%s\"" % value.substr(1)

func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = 0.2
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(evaluate)
	
	text_changed.connect(timer.start.unbind(1))

func evaluate():
	var result: Variant
	if text.is_empty():
		result = null
	elif text.begins_with("@") or text.begins_with("$") or text.begins_with("%"):
		result = text
	else:
		var expression := Expression.new()
		if expression.parse(text) != OK:
			modulate = Color.RED
			return
		
		result = expression.execute()
		if expression.has_execute_failed():
			modulate = Color.RED
			return
	
	modulate = Color.WHITE
	
	sync = true
	value = result
	sync = false
