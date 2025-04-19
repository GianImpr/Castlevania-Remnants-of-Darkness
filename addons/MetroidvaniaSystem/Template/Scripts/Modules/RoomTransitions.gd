## A MetSysModule that handles room transitions.
##
## The module connects to [signal MetroidvaniaSystem.room_changed]. When room changes, the new scene gets is loaded via [code]load_room()[/code] method. If MetSysGame has a player set, the player will be automatically teleported to the correct entrance.
extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysModule.gd"

var player: Node2D

func _initialize():
	player = game.player
	assert(player)
	MetSys.room_changed.connect(_on_room_changed, CONNECT_DEFERRED)

func _on_room_changed(target_room: String):
	player.get_tree().paused = true
	if Global.screen == Global.ScreenType.NONE:
		Global.screen = Global.ScreenType.TRANSITION
	Global.fade_screen.animation.play("fade_in")
	await Global.fade_screen.animation.animation_finished
	if target_room == MetSys.get_current_room_name():
		# This can happen when teleporting to another room.
		return
	
	var prev_room_instance := MetSys.get_current_room_instance()
	if prev_room_instance:
		prev_room_instance.get_parent().remove_child(prev_room_instance)
	
	await game.load_room(target_room)
	
	if prev_room_instance:
		player.position -= MetSys.get_current_room_instance().get_room_position_offset(prev_room_instance)
		if player.innocent_devil != null:
			player.innocent_devil.position = Vector2(player.position.x - 100*player.facing_position, player.position.y)
		prev_room_instance.queue_free()
		
	if MetSys.get_current_room_instance().show_name_ID > 0 and not Global.player.stats.stage_name_flags[MetSys.get_current_room_instance().show_name_ID]:
		Global.stage_presentation.play(MetSys.get_current_room_instance().stage_name)
		Global.player.stats.stage_name_flags[MetSys.get_current_room_instance().show_name_ID] = true
		Global.fade_screen.animation.speed_scale = 0.2
		await Global.stage_presentation.animation.animation_finished
	
	if Global.screen == Global.ScreenType.TRANSITION or Global.screen == Global.ScreenType.EVENT:
		Global.screen = Global.ScreenType.NONE
		player.get_tree().paused = false
	Global.fade_screen.animation.play_backwards("fade_in")
	await Global.fade_screen.animation.animation_finished
	Global.fade_screen.animation.speed_scale = 1
