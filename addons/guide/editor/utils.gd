## Removes and frees all children of a node.
static func clear(node:Node):
	if not is_instance_valid(node):
		return
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


## Checks if the given resource is an inline resource. If so, returns a shallow copy,
## otherwise returns the resource. If the resource is null, returns null.
static func duplicate_if_inline(resource:Resource) -> Resource:
	if is_inline(resource):
		return resource.duplicate()
	return resource
	

## Checks if the given resource is an inline resource.
static func is_inline(resource:Resource) -> bool:
	if resource == null:
		return false
	return resource.resource_path.contains("::") or resource.resource_path == ""