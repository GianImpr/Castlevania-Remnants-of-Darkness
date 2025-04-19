extends StaticBody2D
class_name TutorialScreenTrigger
@export var tutorial_id: TutorialScreen.Tutorial

# Gets function from TutorialScreen
static var setTutorial: Callable

# Trigger the tutorial box if player enters the trigger zone and a condition is met
func _on_area_2d_body_entered(body: Node2D) -> void:
	if Global.player.stats.tutorial_flags[tutorial_id]:
		queue_free()
		return
	
	setTutorial.bind(tutorial_id).call()
	var condition: String = TutorialScreen.current_tutorial.condition
	if not (condition == null or condition == ""):
		if not run_condition(condition):
			return
	Global.tutorial_screen.activate()
	Global.player.stats.tutorial_flags[tutorial_id] = true

# Evaluates the condition by transforming it into a script and executing it in real time
func run_condition(code: String):
	var script = GDScript.new()
	script.set_source_code("static func _eval():\n\t" + "return " + code)
	script.reload()
	return script._eval()
