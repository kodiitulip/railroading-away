extends Node2D
class_name TrackSwitch

@onready var main_track: Track = $MainTrack as Track
@onready var left_track: Track = $LeftTrack as Track
@onready var right_track: Track = $RightTrack as Track
@onready var button: Button = $Button
var turn: bool = false:
	set = switch_track


func  _ready() -> void:
	main_track._link_track_at_tail(right_track)


func switch_track(value: bool) -> void:
	turn = value
	button.text = '<<' if turn else '>>'
	
	if turn:
		main_track._link_track_at_tail(left_track)
	else:
		main_track._link_track_at_tail(right_track)


func  _process(_delta: float) -> void:
	button.disabled = is_busy()
	_kick_switch()
	pass


func _kick_switch() -> void:
	if check_for_bogie(right_track) and is_busy():
		button.button_pressed = false
	elif check_for_bogie(left_track) and is_busy():
		button.button_pressed = true
	


func is_busy() -> bool:
	var empty = !check_for_bogie(right_track) and \
				!check_for_bogie(left_track) and \
				!check_for_bogie(main_track)
	
	return !empty


func check_for_bogie(track: Track) -> bool:
	var has_bogie: bool = false
	for child in track.get_children():
		if child is Bogie:
			has_bogie = true
		else:
			continue
	return has_bogie


func _on_button_toggled(toggled_on: bool) -> void:
	turn = toggled_on
