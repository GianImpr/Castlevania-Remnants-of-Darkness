extends Sprite2D
class_name DevilForging
@export var innocent_devil_scene: PackedScene
@export var event_id: int
@export var animation: AnimationPlayer
@export var forging_particles: GPUParticles2D
var can_forge: int = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.game.disable_lights:
		forging_particles.amount /= 10
	if Global.player.stats.event_flags[event_id]:
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_forge and Global.player.state_machine.current_state is HectorIdle and Input.is_action_just_pressed("up_arrow"):
		Global.player.stats.event_flags[event_id] = true
		Global.player.tap_up.dismiss()
		animation.play("forging")
		Global.player.freeze()
		await animation.animation_finished
		queue_free()

func _on_forge_trigger_body_entered(body: Node2D) -> void:
	can_forge = true
	Global.player.tap_up.appear()

func _on_forge_trigger_body_exited(body: Node2D) -> void:
	can_forge = false
	Global.player.tap_up.dismiss()

func forgeInnocentDevil():
	var innocent_devil: Faerie = innocent_devil_scene.instantiate()
	Global.player.pocket_size += 1
	get_parent().get_parent().add_child(innocent_devil)
	innocent_devil.global_position = global_position
	innocent_devil.state_machine.current_state.Transitioned.emit(innocent_devil.state_machine.current_state, "freeze")
	if Global.player.innocent_devil == null:
		Global.player.innocent_devil = innocent_devil
		const FULL_HEALING: int = 9999
		Global.player.heal_innocent(FULL_HEALING)
		Global.player.innocent_devil_pocket.append(innocent_devil.createInnocentDevilEntry())
		Global.player.innocent_devil_scene = innocent_devil_scene

func unfreezePlayer():
	Global.player.unfreeze()
