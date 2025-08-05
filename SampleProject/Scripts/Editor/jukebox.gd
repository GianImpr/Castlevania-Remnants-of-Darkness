@tool
extends Node
class_name Jukebox

enum Track {
	GARIBALDI,
	SAVE_ROOM,
	WIND_SFX,
	ENCOUNTER,
	FOLLOWERS,
	INNOCENT_DEVIL,
	BOSS_1,
	FOREST,
	CAVE
}

const tracks: Array[String] = ["garibaldi", "save_room", "wind_sfx", "encounter", "followers", "innocent_devil", "boss_1", "forest", "cave"]
@export var audio: AudioStreamPlayer
@export var current_music: Track
@export var play: bool:
	set(value):
		audio.play()
		
@export var stop: bool:
	set(value):
		audio.stop()
