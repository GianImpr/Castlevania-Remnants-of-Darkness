## Helper class for modelling sets
var _values:Dictionary = {}

func add(value:Variant) -> void:
	_values[value] = value
	
	
func remove(value:Variant) -> void:
	_values.erase(value)
	

func clear() -> void:
	_values.clear()
	
func is_empty() -> bool:
	return _values.is_empty()
	
	
func pull() -> Variant:
	if is_empty():
		return null
	
	var key = _values.keys()[0]
	remove(key)
	return key
	
	
func has(value:Variant) -> bool:
	return _values.has(value)

## Returns the first item for which the given matcher function returns
## a true value.
func first_match(matcher:Callable) -> Variant:
	for key in _values.keys():
		if matcher.call(key):
			return key
	return null

func values() -> Array:
	return _values.keys()
