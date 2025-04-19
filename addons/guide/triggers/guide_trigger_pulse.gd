@tool
## A trigger that activates when the input is pushed down and then repeatedly sends trigger events at a fixed interval.
## Note: the trigger will be either triggering or ongoing until the input is released.
## Note: at most one pulse will be emitted per frame.
class_name GUIDETriggerPulse
extends GUIDETrigger

## If true, the trigger will trigger immediately when the input is actuated. Otherwise, the trigger will wait for the initial delay.
@export var trigger_on_start:bool = true
## The delay after the initial actuation before pulsing begins.
@export var initial_delay:float = 0.3:
	set(value):
		initial_delay = max(0, value)

## The interval between pulses. Set to 0 to pulse every frame.
@export var pulse_interval:float = 0.1:
	set(value):
		pulse_interval = max(0, value)

## Maximum number of pulses. If <= 0, the trigger will pulse indefinitely.
@export var max_pulses:int = 0

var _delay_until_next_pulse:float = 0
var _emitted_pulses:int = 0

func _update_state(input:Vector3, delta:float, value_type:GUIDEAction.GUIDEActionValueType) -> GUIDETriggerState:
	if _is_actuated(input, value_type):
		if not _is_actuated(_last_value, value_type):
			# we went from "not actuated" to actuated, pulsing starts
			_delay_until_next_pulse = initial_delay
			if trigger_on_start:
				return GUIDETriggerState.TRIGGERED
			else:
				return GUIDETriggerState.ONGOING
			
		# if we already are pulsing and have exceeded the maximum number of pulses, we will not pulse anymore.
		if max_pulses > 0 and _emitted_pulses >= max_pulses:
			return GUIDETriggerState.NONE	
		
		# subtract the delta from the delay until the next pulse
		_delay_until_next_pulse -= delta
		
		if _delay_until_next_pulse > 0:
			# we are still waiting for the next pulse, nothing to do.
			return GUIDETriggerState.ONGOING
		
		# now delta could be larger than our pulse, in which case we loose a few pulses.
		# as we can pulse at most once per frame.

		# in case someone sets the pulse interval to 0, we will pulse every frame.
		if is_equal_approx(pulse_interval, 0):
			_delay_until_next_pulse = 0
			if max_pulses > 0:
				_emitted_pulses += 1
			return GUIDETriggerState.TRIGGERED
			
		# Now add the delay until the next pulse
		_delay_until_next_pulse += pulse_interval
		
		# If the interval is really small, we can potentially have skipped some pulses
		if _delay_until_next_pulse <= 0: 
			# we have skipped some pulses
			var skipped_pulses:int = int(-_delay_until_next_pulse / pulse_interval)
			_delay_until_next_pulse += skipped_pulses * pulse_interval
			if max_pulses > 0:
				_emitted_pulses += skipped_pulses
				if _emitted_pulses >= max_pulses:
					return GUIDETriggerState.NONE
		
		# Record a pulse and return triggered
		if max_pulses > 0:
			_emitted_pulses += 1
		return GUIDETriggerState.TRIGGERED
		
	# if the input is not actuated, then the trigger is not triggered.
	_emitted_pulses = 0
	_delay_until_next_pulse = 0
	return GUIDETriggerState.NONE
		
		
func _editor_name() -> String:
	return "Pulse"		


func _editor_description() -> String:
	return "Fires at an interval while the input is actuated."
