extends State
class_name GhostMove
@export var speed: float
var tween

func enter():
	animation.play("move", -1, 1.5)
	tween = get_tree().create_tween()
	tween.tween_property(player, "velocity", Vector2(speed * (1-int(in_front_of_player())*2), speed * (1-int(is_below_player())*2)), 1)
	tween.connect("finished", redoTween)
	
func exit():
	tween.kill()
	
func Update(delta: float):
	can_turnaround()
	enemy_can_die()

func Physics_Update(delta: float):
	pass

func redoTween():
	tween = get_tree().create_tween()
	var speedvar = Vector2(speed * (1-int(in_front_of_player())*2), speed * (1-int(is_below_player())*2))
	tween.tween_property(player, "velocity", speedvar, 1)
	tween.connect("finished", redoTween)


func _on_area_2d_body_entered(body: Node2D) -> void:
	Transitioned.emit(self, "bounce")
