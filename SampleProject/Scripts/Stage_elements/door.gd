extends RigidBody2D
@export var flipped_to_left: bool
@export var sprite: Sprite2D
@export var aura: Sprite2D
@export var animation: AnimationPlayer
@export var hitbox: CollisionShape2D
@export var collision_box: CollisionShape2D
@export var sound: PolyphonicAudio
@export var area: Area2D
@export var spritesheet: CompressedTexture2D
@export var aura_sheet: CompressedTexture2D
@export var aura_color: Color = Color(0, 0.58, 0.746)
@export var spawn_cooldown: Timer
var can_open_door: bool = false
var needs_to_close: bool = false

func _ready():
	spawn_cooldown.start()
	if spritesheet:
		sprite.texture = spritesheet
		aura.texture = aura_sheet
	aura.modulate = aura_color
	if Global.player.state_machine.current_state is HectorOpeningDoor:
		sprite.frame = 22
		aura.visible = false
		collision_box.disabled = true
		needs_to_close = true
	if flipped_to_left:
		sprite.position.x -= 52
		aura.position.x -= 68
		sprite.scale.x *= -1
		aura.scale *= -1
		hitbox.scale *= -1
		collision_box.scale *= -1
		
func _process(delta: float) -> void:
	if Global.player.state_machine.current_state is HectorRun and can_open_door and Global.player.sprite.flip_h == !flipped_to_left:
		enterDoor()
		
	if animation.is_playing():
		aura.frame = sprite.frame
		
	if needs_to_close and Global.player.state_machine.current_state is HectorOpeningDoor and Global.player.state_machine.current_state.can_close:
		animation.play_backwards("opening")
		sound.play_sound_effect_from_library("open")
		needs_to_close = false
		
	if sprite.frame == 12 and not animation.is_playing():
		animation.play("idle")
		sound.play_sound_effect_from_library("close")
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	can_open_door = true

func enterDoor():
	animation.play("opening")
	sound.play_sound_effect_from_library("open")
	Global.player.state_machine.current_state.Transitioned.emit(Global.player.state_machine.current_state, "opening_door")


func _on_area_2d_body_exited(body: Node2D) -> void:
	can_open_door = false


func _on_spawn_cooldown_timeout() -> void:
	area.set_deferred("monitoring", true)
