@icon("res://addons/guide/guide_internal.svg")
class_name GUIDETriggerComboStep
extends Resource

@export var action:GUIDEAction
@export_flags("Triggered:1", "Started:2", "Ongoing:4", "Cancelled:8","Completed:16") 
var completion_events:int = GUIDETriggerCombo.ActionEventType.TRIGGERED
@export var time_to_actuate:float = 0.5


var _has_fired:bool = false

func _prepare():
	if completion_events & GUIDETriggerCombo.ActionEventType.TRIGGERED:
		action.triggered.connect(_fired)
	if completion_events & GUIDETriggerCombo.ActionEventType.STARTED:
		action.started.connect(_fired)
	if completion_events & GUIDETriggerCombo.ActionEventType.ONGOING:
		action.ongoing.connect(_fired)
	if completion_events & GUIDETriggerCombo.ActionEventType.CANCELLED:
		action.cancelled.connect(_fired)
	if completion_events & GUIDETriggerCombo.ActionEventType.COMPLETED:
		action.completed.connect(_fired)
	_has_fired = false
		
		
func _fired():
	_has_fired = true
	
