extends RigidBody2D
class_name DestructibleBody2D

@export_range (2, 10, 2) var blocks_per_side: int = 6
@export var blocks_impulse: float = 600
@export var blocks_gravity_scale: float = 10
@export var debris_max_time: float = 5
@export var remove_debris: bool = false
@export var collision_layers: int = 1
@export var collision_masks: int = 1
@export var collision_one_way: bool = false
@export var explosion_delay: bool = false
@export var fake_explosions_group: String = "fake_explosion_particles"
@export var randomize_seed: bool = false
@export var debug_mode: bool = false
@export var SPEED: Vector2
@export var randomize_speed: bool = false
@export var extra_z_index: int = 0
@export var child_fixed_scale: float = 0

var ps = PhysicsServer2D

var object = {}

var explosion_delay_timer = 0
var explosion_delay_timer_limit = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	object = {
		blocks = [],
		blocks_container = Node2D.new(),
		blocks_gravity_scale = blocks_gravity_scale,
		blocks_impulse = blocks_impulse,
		blocks_per_side = blocks_per_side,
		can_detonate = true,
		collision_extents = Vector2(),
		collision_layers = collision_layers,
		collision_masks = collision_masks,
		collision_name = null,
		collision_one_way = collision_one_way,
		collision_position = Vector2(),
		debris_max_time = debris_max_time,
		debris_timer = Timer.new(),
		detonate = false,
		frame = 0,
		has_detonated = false,
		has_particles = false,
		height = 0,
		hframes = 1,
		offset = Vector2(),
		parent = get_parent(),
		particles = null,
		remove_debris = remove_debris,
		sprite_name = null,
		vframes = 1,
		width = 0
	}
	
	# Add a unique name to 'blocks_container'.
	object.blocks_container.name = self.name + "_blocks_container"

	# Randomize the seed of the random number generator.
	if randomize_seed: randomize()

	if not self is RigidBody2D:
		print("ERROR: The '%s' node must be a 'RigidBody2D'" % self.name)
		object.can_detonate = false
		return

	for child in get_children():
		if child is Sprite2D:
			object.sprite_name = child.name

		if child is CollisionShape2D:
			object.collision_name = child.name

	if not object.sprite_name and not object.collision_name:
		print("ERROR: The 'RigidBody2D' (%s) must contain at least a 'Sprite2D' and a 'CollisionShape2D'." % self.name)
		object.can_detonate = false
		return

	if object.blocks_per_side > 10:
		print("ERROR: Too many blocks in '%s'! The maximum is 10 blocks per side." % self.name)
		object.can_detonate = false
		return

	if object.blocks_per_side % 2 != 0:
		print("ERROR: 'blocks_per_side' in '%s' must be an even number!" % self.name)
		object.can_detonate = false
		return

	# Set the debris timer.
	object.debris_timer.connect("timeout", Callable(self, "_on_debris_timer_timeout")) 
	object.debris_timer.set_one_shot(true)
	object.debris_timer.set_wait_time(object.debris_max_time)
	object.debris_timer.name = "debris_timer"
	add_child(object.debris_timer, true)

	if debug_mode: print("--------------------------------")
	if debug_mode: print("Debug mode for '%s'" % self.name)
	if debug_mode: print("--------------------------------")

	# Use vframes and hframes to divide the sprite.
	find_child(object.sprite_name).vframes = object.blocks_per_side
	find_child(object.sprite_name).hframes = object.blocks_per_side
	object.vframes = find_child(object.sprite_name).vframes
	object.hframes = find_child(object.sprite_name).hframes

	if debug_mode: print("object's blocks per side: ", object.blocks_per_side)
	if debug_mode: print("object's total blocks: ", object.blocks_per_side * object.blocks_per_side)

	# Check if the sprite is using 'Region' to get the proper width and height.
	if find_child(object.sprite_name).region_enabled:
		object.width = float(find_child(object.sprite_name).region_rect.size.x)
		object.height = float(find_child(object.sprite_name).region_rect.size.y)
	else:
		object.width = float(find_child(object.sprite_name).texture.get_width())
		object.height = float(find_child(object.sprite_name).texture.get_height())

	if debug_mode: print("object's width: ", object.width)
	if debug_mode: print("object's height: ", object.height)

	# Check if the sprite is centered to get the offset.
	if find_child(object.sprite_name).centered:
		object.offset = Vector2(object.width / 2, object.height / 2)

		if debug_mode: print("object is centered!")
		if debug_mode: print("object's offset: ", object.offset)

	object.collision_extents = Vector2((object.width / 2) / object.hframes,\
										(object.height / 2) / object.vframes)

	if debug_mode: print("object's collision_extents: ", object.collision_extents)

	object.collision_position = Vector2((ceil(object.collision_extents.x) - object.collision_extents.x) * -1,\
										(ceil(object.collision_extents.y) - object.collision_extents.y) * -1)

	if debug_mode: print("object's collision_position: ", object.collision_position)

	# Set each block's properties.
	for n in range(object.vframes * object.hframes):
		# Duplicate the object.
		var duplicated_object = self.duplicate(8)
		# Add a unique name to each block.
		duplicated_object.name = self.name + "_block_" + str(n)
		# Append it to the blocks array.
		object.blocks.append(duplicated_object)

		# Create a new collision shape for each block.
		var shape = RectangleShape2D.new()
		shape.extents = object.collision_extents

		ps.body_set_mode(object.blocks[n], PhysicsServer2D.BODY_MODE_STATIC)
		object.blocks[n].find_child(object.sprite_name).vframes = object.vframes
		object.blocks[n].find_child(object.sprite_name).hframes = object.hframes
		object.blocks[n].find_child(object.sprite_name).frame = n
		object.blocks[n].find_child(object.collision_name).shape = shape
		object.blocks[n].find_child(object.collision_name).position = object.collision_position

		if object.collision_one_way: object.blocks[n].find_child(object.collision_name).one_way_collision = true

		if debug_mode: object.blocks[n].modulate = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1), 0.9)

	# Position each block in place to create the whole sprite.
	for x in range(object.hframes):
		for y in range(object.vframes):
			object.blocks[object.frame].position = Vector2(\
				y * (object.width / object.hframes) - object.offset.x + object.collision_extents.x + position.x,\
				x * (object.height / object.vframes) - object.offset.y + object.collision_extents.y + position.y)

			if debug_mode: print("object[", object.frame, "] position: ", object.blocks[object.frame].position)

			object.frame += 1

	call_deferred("add_children", object)

	if debug_mode: print("--------------------------------")

func _physics_process(delta):
	if Input.is_key_pressed(KEY_Q) and object.can_detonate or \
		Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and object.can_detonate:
		# This is what triggers the explosion, setting 'object.detonate' to 'true'.
		object.detonate = true

	if object.can_detonate and object.detonate:
		detonate()

	if object.has_detonated:
		# Add a delay of 'delta' before counting the blocks.
		# Sometimes the last one doesn't get counted.
		if explosion_delay:
			# Removed the yield timer because it was throwing
			# 'Resumed after yield, but class instance is gone' errors
			# when freeing the blocks.
			# yield(get_tree().create_timer(delta), "timeout")
			explosion_delay_timer_limit = delta
			explosion_delay_timer += delta
			if explosion_delay_timer > explosion_delay_timer_limit:
				explosion_delay_timer -= explosion_delay_timer_limit
				# Remove the parent node after the last block is gone.
				if object.blocks_container.get_child_count() == 0:
					object.parent.queue_free()
		else:
			# Remove the parent node after the last block is gone.
			if object.blocks_container.get_child_count() == 0:
				object.parent.queue_free()

func _integrate_forces(state):
	explosion(state.step)

func add_children(child_object):
	for i in range(child_object.blocks.size()):
		child_object.blocks_container.add_child(child_object.blocks[i], true)

	child_object.parent.add_child(child_object.blocks_container, true)

	# Move the self element faaaar away, instead of removing it,
	# so we can still use the script and its functions.
	self.position = Vector2(-999999, -999999)
#	self.queue_free()

func detonate():
	object.can_detonate = false
	object.has_detonated = true

	# Check if the parent node has particles as a child.
	for child in object.parent.get_children():
		if child is GPUParticles2D or child is CPUParticles2D or child.is_in_group(fake_explosions_group):
			object.particles = child
			object.has_particles = true

	if object.has_particles:
		if object.particles is GPUParticles2D or object.particles is CPUParticles2D:
			object.particles.emitting = true
		elif object.particles.is_in_group(fake_explosions_group):
			object.particles.particles_explode = true

	for i in range(object.blocks_container.get_child_count()):
		var child = object.blocks_container.get_child(i)

		var child_gravity_scale = blocks_gravity_scale
		child.gravity_scale = child_gravity_scale

		var child_scale = randf_range(0.5, 1.5)
		if child_fixed_scale:
			child_scale = child_fixed_scale
		child.find_child(object.sprite_name).scale = Vector2(child_scale, child_scale)
		child.find_child(object.collision_name).scale = Vector2(child_scale, child_scale)

		child.mass = child_scale

		child.set_collision_layer_value(object.collision_layers, true)
		child.set_collision_mask_value(object.collision_masks, true)
		child.set_collision_layer_value(1, false)
		child.set_collision_layer_value(3, false)
		child.set_collision_mask_value(1, true)
		
		if randomize_speed:
			child.linear_velocity = Vector2(randf_range(-SPEED.x, SPEED.x), randf_range(0, SPEED.y))
		else:
			child.linear_velocity = SPEED

		child.z_index = extra_z_index+0 if randf() < 0.5 else extra_z_index-1

		var child_color = randf_range(100, 255) / 255
		var color_tween = create_tween().bind_node(self)
		color_tween.tween_property(child, "modulate", Color(child_color, child_color, child_color, 1.0), 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
		color_tween.play()
		ps.call_deferred("body_set_mode", child, PhysicsServer2D.BODY_MODE_RIGID)

	object.debris_timer.start()

func explosion(delta):
	if object.detonate:
		if debug_mode: print("'%s' object exploded!" % self.name)

		for i in range(object.blocks_container.get_child_count()):
			var child = object.blocks_container.get_child(i)
 
			child.apply_central_impulse(Vector2(randf_range(-blocks_impulse, blocks_impulse), -blocks_impulse))

		# Add a delay before setting 'object.detonate' to 'false'.
		# Sometimes 'object.detonate' is set to 'false' so quickly that the explosion never happens.
		# If this happens, try setting 'explosion_delay' to 'true'.
		if explosion_delay:
			# Removed the yield timer because it was throwing
			# 'Resumed after yield, but class instance is gone' errors
			# when freeing the blocks.
			# yield(get_tree().create_timer(delta), "timeout")
			explosion_delay_timer_limit = delta
			explosion_delay_timer += delta
			if explosion_delay_timer > explosion_delay_timer_limit:
				explosion_delay_timer -= explosion_delay_timer_limit
				object.detonate = false
		else:
			object.detonate = false

func _on_debris_timer_timeout():
	if debug_mode: print("'%s' object's debris timer (%ss) timed out!" % [self.name, debris_max_time])

	for i in range(object.blocks_container.get_child_count()):
		var child = object.blocks_container.get_child(i)

		if not object.remove_debris:
			ps.body_set_mode(child, PhysicsServer2D.BODY_MODE_STATIC)
			child.find_child(object.collision_name).disabled = true

			# Remove the self element as we don't need it anymore.
			self.queue_free()
		else:
			get_tree().create_tween().tween_property(child, "modulate", Color(1,1,1,0), 1.0).finished.connect(_on_opacity_tween_completed.bind(child))


func _on_opacity_tween_completed(obj):
	obj.queue_free()
