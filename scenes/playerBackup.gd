extends CharacterBody2D


const SPEED = 260.0
const JUMP_VELOCITY = -700.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hector_noises: AudioStreamPlayer2D = $"Hector noises"
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var reset_position: Vector2
var abilities: Array[StringName]
var double_jump: bool
var prev_on_floor: bool

func anim(animation):
	return animation == animated_sprite.get_animation()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity()*2 * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not anim("hurt") and not anim("hurt_air"):
		velocity.y = JUMP_VELOCITY
		hector_noises.set_stream(load("res://assets/sounds/jump.MP3"))
		hector_noises.play()
		
	if ((Input.is_action_just_released("jump") and anim("jump")) or anim("hurt_air")) and velocity.y < 0:
		velocity.y *= 0.95*delta
		
	# Handle crouch
	if Input.is_action_just_pressed("crouch") and is_on_floor() and not anim("hurt") and not anim("hurt_air"):
		animated_sprite.play("crouch")
		
	if Input.is_action_just_released("crouch") and anim("crouch"):
		animated_sprite.play("rising")
	
	if anim("rising") and animated_sprite.get_frame() == 4:
		animated_sprite.play("idle")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip sprite
	if direction > 0 and not anim("hurt") and not anim("hurt_air"):
		animated_sprite.flip_h = false
	elif direction < 0 and not anim("hurt") and not anim("hurt_air"):
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if (direction == 0 and not Input.is_anything_pressed() and not anim("rising") and not anim("landing")) or anim("falling") or anim("jump") or anim("hurt") or anim("hurt_air") or (anim("run") and direction == 0):
			if anim("run"):
				animated_sprite.play("run_end")
			elif anim("run_end") and animated_sprite.get_frame() == 5 or anim("hurt") and animated_sprite.get_frame() == 4:
				animated_sprite.play("idle")
			elif anim("jump") or anim("falling"):
				animated_sprite.play("landing")
				hector_noises.set_stream(load("res://assets/sounds/land.MP3"))
				hector_noises.play()
			elif anim("hurt_air"):
				animated_sprite.play("hard_landing")
				
		elif not Input.is_action_pressed("crouch") and direction != 0 and not anim("run_start") and not anim("run") and not anim("hurt") and not anim("hard_landing"):
			animated_sprite.play("run_start")
		
		if anim("run_start") and animated_sprite.get_frame() == 1:
			animated_sprite.play("run")
			
		if anim("landing") and animated_sprite.get_frame() == 2:
			animated_sprite.play("idle")
			
		if anim("hard_landing") and animated_sprite.get_frame() == 7:
			animated_sprite.play("rising")
			
			
	if anim("hurt_air"):
		velocity.x = min(direction, -1) * 300
			
	elif velocity.y < 0:
		animated_sprite.play("jump")
	elif velocity.y > 0 and not anim("jump") and not anim("hurt_air") and not anim("falling"):
		animated_sprite.play("falling")
	
	if direction and not anim("crouch") and not anim("hurt") and not anim("hurt_air") and not anim("hard_landing"):
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if anim("jump") and (animated_sprite.get_frame() >= 1 or animated_sprite.get_frame() <= 4):
		collision_shape_2d.set_position(Vector2(0.5, 5.0))
	else:
		collision_shape_2d.set_position(Vector2(0.5, 12.5))
			
	move_and_slide()

func kill():
	# Player dies, reset the position to the entrance.
	position = reset_position
	Game.get_singleton().load_room(MetSys.get_current_room_name())

func on_enter():
	# Position for kill system. Assigned when entering new room (see Game.gd).
	reset_position = position
