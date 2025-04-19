@tool
extends GUIDEIconRenderer

func supports(input:GUIDEInput) -> bool:
	return input is GUIDEInputAction
	
func render(input:GUIDEInput) -> void:
	pass
 
func cache_key(input:GUIDEInput) -> String:
	return "0ecd6608-ba3c-4fc2-83f7-ad61736f1106"  # we only have one output, so same cache key
