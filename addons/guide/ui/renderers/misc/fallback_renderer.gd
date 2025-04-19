@tool
extends GUIDEIconRenderer

func supports(input:GUIDEInput) -> bool:
	return true
	
func render(input:GUIDEInput) -> void:
	pass
 
func cache_key(input:GUIDEInput) -> String:
	return "2e130e8b-d5b3-478c-af65-53415adfd6bb"  # we only have one output, so same cache key
