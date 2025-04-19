extends RigidBody2D
@export var direction: int
@export var animation: AnimationPlayer
@export var aura: Sprite2D
@export var detect_hitbox: Area2D
@export var sound: PolyphonicAudio
var can_sit: bool = false
var opened_menu: bool = false
var player_state = Global.player.state_machine.current_state
@export var save_menu_scene: PackedScene

func _process(delta: float) -> void:
	player_state = Global.player.state_machine.current_state
	if can_sit and Input.is_action_just_pressed("up_arrow") and Global.player.is_on_floor() and not Input.is_action_pressed("jump") and (player_state is HectorIdle or player_state is HectorRunEnd):
		Global.player.tap_up.dismiss()
		player_state.Transitioned.emit(player_state, "sit_down")
		Global.player.facing_position = direction
		Global.player.sprite.flip_h = (direction < 0)
		Global.player.stats.Stats["HP"] = Global.player.stats.Stats["MHP"]
		Global.player.stats.Stats["MP"] = Global.player.stats.Stats["MMP"]
		if Global.player.innocent_devil != null:
			Global.player.heal_innocent(9999)
		await player_state.animation.animation_finished
		opened_menu = true
		var save_menu = save_menu_scene.instantiate()
		add_child(save_menu)
		
		
	if player_state is HectorSitDown and not player_state.animation.is_playing() and Input.is_action_just_pressed("circle")  and not opened_menu:
		player_state.Transitioned.emit(player_state, "stand_up")
		if detect_hitbox.monitoring:
			Global.player.tap_up.appear()


func _on_area_2d_body_entered(body: Node2D) -> void:
	can_sit = true
	Global.player.tap_up.appear()
	animation.play("can_sit")
	setShaderParams(1.5, 2, 1)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if detect_hitbox.monitoring:
		can_sit = false
		Global.player.tap_up.dismiss()
		animation.play("idle")
		setShaderParams(0.5, 1, 2)
	
func setShaderParams(min_intensity: float, max_intensity: float, speed: float):
	aura.material.set_shader_parameter("min_intensity", min_intensity)
	aura.material.set_shader_parameter("max_intensity", max_intensity)
	aura.material.set_shader_parameter("speed", speed)
