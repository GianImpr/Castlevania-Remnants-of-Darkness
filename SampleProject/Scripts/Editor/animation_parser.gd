@tool
extends AnimationPlayer
class_name AnimationParser

@export var base_frame: int = 0
@export var animation_name: String = ""
@export var animation_data: JSON
@export_tool_button("Parse animation", "Animation") var button: Callable = parseAnimation

func testParse() -> void:
	if animation_data == null:
		push_warning("Animation to parse has no data.")
		return
	
	var total_duration: float = 0
	var anim_data: Array = animation_data.data["frames"]
	var meta_data: Array = animation_data.data["meta"]["frameTags"]
	for meta in meta_data:
		var true_frame: int = meta["name"].substr("true_frame:".length()).to_int()-1
		var frame: int = meta["from"]
		print("Frame: " + str(frame) + " has true frame = " + str(true_frame))
	
	for i in range(0, anim_data.size()):
		print("frame " + str(i) + " duration: " + str(anim_data[i]["duration"]) + " ms")
		total_duration += float(anim_data[i]["duration"])
	print("Duration: " + str(total_duration) + " ms")

func parseAnimation() -> void:
	if animation_data == null:
		push_warning("Animation to parse has no data.")
		return
	
	if has_animation_library(animation_name):
		remove_animation_library(animation_name)
	var anim_library := AnimationLibrary.new()
	var anim := Animation.new()
	anim.loop_mode = Animation.LOOP_NONE

	var total_duration: float = 0
	var anim_data: Array = animation_data.data["frames"]
	var meta_data: Array = animation_data.data["meta"]["frameTags"]
	var track_id := anim.add_track(Animation.TYPE_VALUE)
	var target_path := ".:frame"
	anim.track_set_path(track_id, target_path)
	var cur_frame: int = 0
	for meta in meta_data:
		var true_frame: int = meta["name"].substr("true_frame:".length()).to_int()-1
		var frame: int = meta["from"]

	var timeline_to_sprite_frame: Array[int] = []
	timeline_to_sprite_frame.resize(anim_data.size())

	var cur_unique_frame: int = 0

	for i in range(anim_data.size()):
		var target_timeline_frame: int = -1

		for meta in meta_data:
			var tag_name: String = meta["name"]
			if tag_name.begins_with("true_frame:"):
				var frame_from: int = meta["from"]
				if frame_from == i:
					target_timeline_frame = tag_name.substr("true_frame:".length()).to_int() - 1
					break

		if target_timeline_frame != -1:
			timeline_to_sprite_frame[i] = timeline_to_sprite_frame[target_timeline_frame]
		else:
			timeline_to_sprite_frame[i] = base_frame + cur_unique_frame
			cur_unique_frame += 1

		var frame_to_use: int = timeline_to_sprite_frame[i]
		anim.track_insert_key(track_id, total_duration, frame_to_use)
		
		var frame_duration: float = float(anim_data[i]["duration"]) / 1000.0
		total_duration += frame_duration
		
	anim.length = total_duration
	anim_library.add_animation(animation_name, anim)
	add_animation_library(animation_name, anim_library)
	play(animation_name + "/" + animation_name)
