extends State
class_name SlaughtererSpitting
@export var fireball_scene: PackedScene
@export var FIREBALL_SPEED_MULTIPLIER: float
@export var FIREBALL_SPAWN_OFFSET: Vector2
const MAX_SPITS: int = 3
var spits: int = 0

func enter():
	spits = 0
	animation.play("spit")
	
func exit():
	pass

func Update(delta: float):
	enemy_can_die()
	
	if not animation.is_playing() and spits < MAX_SPITS and Global.game.difficulty == Game.Difficulty.CRAZY:
		animation.seek(0.2)
		spits += 1
	elif not animation.is_playing():
		Transitioned.emit(self, "idle")

func Physics_Update(delta: float):
	pass

func spawnFireball() -> void:
	var fireball = fireball_scene.instantiate()
	fireball.facing_position = player.facing_position
	fireball.stats.thrower_ATK = player.stats.ATK
	fireball.SPEED.x = abs(Global.player.global_position.x - player.global_position.x) * player.facing_position * FIREBALL_SPEED_MULTIPLIER
	fireball.global_position = Vector2(player.global_position.x + FIREBALL_SPAWN_OFFSET.x * player.facing_position, player.global_position.y + FIREBALL_SPAWN_OFFSET.y)
	MetSys.get_current_room_instance().add_child(fireball)
