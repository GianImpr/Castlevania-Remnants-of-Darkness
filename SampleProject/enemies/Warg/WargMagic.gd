extends State
class_name WargMagic
@export var offensive_fire_pillar_scene: PackedScene
@export var fire_pillar_respawn_timer: Timer
var current_pillar: int = 0
const FIRE_PILLAR_DISTANCE: float = 76
const INITIAL_FIRE_PILLAR_POSITION: Vector2 = Vector2(150, 66)
const MAX_PILLARS: int = 7

func _ready() -> void:
	fire_pillar_respawn_timer.timeout.connect(spawnFirePillar)

func enter():
	player.velocity.x = 0
	current_pillar = 0
	animation.play("cast_magic")
	
func exit():
	if not fire_pillar_respawn_timer.is_stopped():
		fire_pillar_respawn_timer.stop()

func Update(delta: float):
	enemy_can_die()
	if current_pillar == MAX_PILLARS:
		fire_pillar_respawn_timer.stop()
		if not animation.is_playing():
			Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass
	
func startSpawningFirePillars() -> void:
	fire_pillar_respawn_timer.start()

func spawnFirePillar() -> void:
	var fire_pillar = offensive_fire_pillar_scene.instantiate()
	fire_pillar.stats.thrower_ATK = player.stats.ATK
	MetSys.get_current_room_instance().add_child(fire_pillar)
	fire_pillar.global_position.y = player.global_position.y + INITIAL_FIRE_PILLAR_POSITION.y
	fire_pillar.global_position.x = player.global_position.x + (INITIAL_FIRE_PILLAR_POSITION.x + current_pillar*FIRE_PILLAR_DISTANCE) * player.facing_position
	current_pillar += 1
