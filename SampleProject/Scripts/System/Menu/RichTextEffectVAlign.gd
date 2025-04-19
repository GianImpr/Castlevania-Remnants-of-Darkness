@tool
extends RichTextEffect
class_name RichTextVAlign

var bbcode := "valign"

func _process_custom_fx(char_fx:CharFXTransform) -> bool:
	char_fx.offset = Vector2.UP * char_fx.env.get("px", 0.0)
	return true
