extends Resource
class_name Artifact

@export var artifact_name: String
@export_multiline var artifact_description: String
@export var ATK: int
@export var DEF: int
@export var STR: int
@export var CON: int
@export var INT: int
@export var SYN: int
@export var RES: int
@export var LCK: int
@export var value: int
@export var glow: Color
@export var max_quantity: int = 1
@export var icon: Texture2D
@export var stat_proc: HectorStats.Parameters
@export var proc_factor: float

enum Artifacts {
	LITTLE_HAMMER,
	MIRACLE_COIN,
	HEART_BROOCH,
	STONE_OF_ALCHEMY,
	BLOOD_STONE,
	PRODIGY_NECKLACE,
	GODDESS_SHIELD
}
