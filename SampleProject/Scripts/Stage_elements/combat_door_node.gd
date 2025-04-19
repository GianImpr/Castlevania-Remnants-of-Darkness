extends Node2D
@export var combat_flag_id: int
@export var should_close: bool
@export var boss_door: bool
@export var init_cooldown: Timer #To avoid detecting the player too early when the room changes
@export var detection: Area2D


func _ready():
	pass


func _on_init_cooldown_timeout() -> void:
	detection.monitoring = true
