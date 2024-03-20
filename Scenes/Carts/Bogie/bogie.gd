extends PathFollow2D
class_name Bogie

signal moved(distance: float)
signal reached_track_tail(bogie: Bogie, distance: float)
signal reached_track_head(bogie: Bogie, distance: float)
signal reached_end_of_track(distance: float)

@onready var area: Area2D = $Area2D

@export_enum("tailward:1", "headward:-1") var direction: int = 1:
	set(value):
		direction = int(clamp(value, -1, 1))
@export var vehicle: TrainVehicle

var follow_distance: float = 32
var leader_bogie: Bogie
var current_track: Track
var current_track_length: float
var can_move: bool = true


func disconnect_from_track(track: Track) -> void:
	if !track:
		return
	
	for conn in reached_track_head.get_connections():
		reached_track_head.disconnect(conn["callable"])
	for conn in reached_track_tail.get_connections():
		reached_track_tail.disconnect(conn["callable"])


func set_track(track: Track) -> void:
	if !track:
		return
	
	disconnect_from_track(current_track)
	
	current_track = track
	current_track_length = track.curve.get_baked_length()
	
	reached_track_head.connect(
		current_track.change_bogie_to_track_at_head
	)
	reached_track_tail.connect(
		current_track.change_bogie_to_track_at_tail
	)
	
	get_parent().remove_child(self)
	current_track.add_child(self)


func move(distance: float) -> void:
	if leader_bogie == null and area.has_overlapping_areas():
		distance *= 0
	
	var new_distance = progress + (distance * direction)
	
	if !_change_track_if_ended(new_distance):
		progress = new_distance
	
	moved.emit(distance)


func _change_track_if_ended(distance: float) -> bool:
	if distance > current_track_length:
		reached_track_tail.emit(self, distance - current_track_length)
		return true
	elif distance < 0:
		reached_track_head.emit(self, distance)
		return true
	return false


func follow(leader: Bogie, distance: float) -> void:
	follow_distance = distance
	direction = leader.direction
	set_track(leader.current_track)
	#progress = leader.progress - follow_distance
	leader_bogie = leader
	reached_end_of_track.connect(leader_bogie.emit_end_of_track)
	move_as_follower(distance)


func move_as_follower(distance: float) -> void:
	move(distance)
	
	if leader_bogie.current_track == current_track:
		var dist = leader_bogie.progress - progress
		if dist < follow_distance * direction:
			progress = leader_bogie.progress - follow_distance * direction


func emit_end_of_track(distance: float) -> void:
	move(-distance)
	reached_end_of_track.emit(distance)
	if leader_bogie == null and vehicle is TrainEngine:
		vehicle.abrupt_stop()
