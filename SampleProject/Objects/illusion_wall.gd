extends TileMapLayer
@export var event_id: int
@export var animation: AnimationPlayer
var can_trigger_faerie: bool = false
var faerie_triggered: bool = false
var trigger_faerie: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.player.stats.event_flags[event_id]:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if trigger_faerie and not faerie_triggered:
		faerie_triggered = true
		Global.player.innocent_devil.funny_wall_destination = Vector2(80, 387)
		Global.player.innocent_devil.wall_event_id = event_id
		Global.player.innocent_devil.state_machine.current_state.Transitioned.emit(Global.player.innocent_devil.state_machine.current_state, "funny_wall")
		Global.player.freeze()
	else:
		trigger_faerie = can_trigger_faerie and Global.player.innocent_devil is Faerie
		
	if Global.player.stats.event_flags[event_id]:
		animation.play("vanishing")
		Global.player.unfreeze()

	
func _on_area_2d_body_entered(body: Node2D) -> void:
	can_trigger_faerie = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	can_trigger_faerie = false
