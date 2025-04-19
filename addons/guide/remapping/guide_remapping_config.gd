@icon("res://addons/guide/guide_internal.svg")
## A remapping configuration. This only holds changes to the context mapping,
## so to get the full input map you need to apply this on top of one or more
## mapping contexts. The settings from this config take precedence over the
## settings from the mapping contexts.
class_name GUIDERemappingConfig
extends Resource

## Dictionary with remapped inputs. Structure is:
## { 
##    mapping_context : {
##         action : {
##            index : bound input
##             ...
##         }, ...
## }		
## The bound input can be NULL which means that this was deliberately unbound.	
@export var remapped_inputs:Dictionary = {}

## Dictionary for additional custom data to store (e.g. modifier settings, etc.)
## Note that this data is completely under application control and it's the responsibility
## of the application to ensure that this data is serializable and gets applied at
## the necessary point in time.
@export var custom_data:Dictionary = {}

## Binds the given input to the given action. Index can be given to have 
## alternative bindings for the same action.
func _bind(mapping_context:GUIDEMappingContext, action:GUIDEAction, input:GUIDEInput, index:int = 0) -> void:
	if not remapped_inputs.has(mapping_context):
		remapped_inputs[mapping_context] = {}
		
	if not remapped_inputs[mapping_context].has(action):
		remapped_inputs[mapping_context][action] = {}
		
	remapped_inputs[mapping_context][action][index] = input
	
	
## Unbinds the given input from the given action. This is a deliberate unbind
## which means that the action should not be triggerable by the input anymore. It 
## its not the same as _clear.	
func _unbind(mapping_context:GUIDEMappingContext, action:GUIDEAction, index:int = 0) -> void:
	_bind(mapping_context, action, null, index)

	
## Removes the given input action binding from this configuration. The action will
## now have the default input that it has in the mapping_context. This is not the 
## same as _unbind.	
func _clear(mapping_context:GUIDEMappingContext, action:GUIDEAction, index:int = 0) -> void:
	if not remapped_inputs.has(mapping_context):
		return
		
	if not remapped_inputs[mapping_context].has(action):
		return
		
	remapped_inputs[mapping_context][action].erase(index)
	
	if remapped_inputs[mapping_context][action].is_empty():
		remapped_inputs[mapping_context].erase(action)
	
	if remapped_inputs[mapping_context].is_empty():
		remapped_inputs.erase(mapping_context)
	
	
## Returns the bound input for the given action name and index. Returns null
## if there is matching binding.
func _get_bound_input_or_null(mapping_context:GUIDEMappingContext, action:GUIDEAction, index:int = 0) -> GUIDEInput:
	if not remapped_inputs.has(mapping_context):
		return null
		
	if not remapped_inputs[mapping_context].has(action):
		return null
		
	return remapped_inputs[mapping_context][action].get(index, null)
	
	
## Returns whether or not this mapping has a configuration for the given combination (even if the 
## combination is set to null).
func _has(mapping_context:GUIDEMappingContext, action:GUIDEAction, index:int = 0) -> bool:
	if not remapped_inputs.has(mapping_context):
		return false
		
	if not remapped_inputs[mapping_context].has(action):
		return false
		
	return remapped_inputs[mapping_context][action].has(index)
