extends Control

@export var labels: Control
@export var buttons: VBoxContainer
@export var animation: AnimationPlayer
@export var default_button: InventoryButton
var resume_game: bool = false
@export var open: bool

func _ready():
	$AnimationPlayer.play("RESET")

func _process(delta: float) -> void:
	resume_game = get_parent().resume_game
