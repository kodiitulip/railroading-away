@tool
extends Path2D
class_name Track

@onready var head_marker: Marker2D = %HeadMarker
@onready var tail_marker: Marker2D = %TailMarker
@onready var crosstie: MeshInstance2D = $Crosstie
@onready var crossties: MultiMeshInstance2D = $Crossties

var track_at_head: Track
var track_at_tail: Track
var busy: bool = false


@export var update: bool = false:
	set = bool_debug
@export var crosstie_distance: float = 8

func _ready() -> void:
	update_visual()


func _process(_delta: float) -> void:
	busy = check_for_bogie(self)


func check_for_bogie(track: Track) -> bool:
	var has_bogie: bool = false
	for child in track.get_children():
		if child is Bogie:
			has_bogie = true
		else:
			continue
	return has_bogie


func update_visual() -> void:
	$Line2D.points = curve.get_baked_points()
	_update_crossties()
	$Tail.progress_ratio = 1
	$Head.progress_ratio = 0


func _update_crossties():
	var cross = crossties.multimesh
	cross.mesh = crosstie.mesh
	
	var curve_length = curve.get_baked_length()
	var crosstie_count = round(curve_length / crosstie_distance)
	cross.instance_count = crosstie_count
	
	for i in range(crosstie_count):
		var t = Transform2D()
		var crosstie_position = curve.sample_baked((i * crosstie_distance) + crosstie_distance/2)
		var next_position = curve.sample_baked((i + 1) * crosstie_distance)
		t = t.rotated((next_position - crosstie_position).normalized().angle())
		t.origin = crosstie_position
		cross.set_instance_transform_2d(i, t)


func bool_debug(_value: bool) -> void:
	update = false
	if _value:
		update_visual()


func _link_track_at_head(track: Track) -> void:
	if track_at_head == track or !track:
		return
	
	var head_pos = track.head_marker.global_position.round()
	var tail_pos = track.tail_marker.global_position.round()
	var self_head = head_marker.global_position
	
	if head_pos.is_equal_approx(self_head):
		track._link_track_at_head.call_deferred(self)
	elif tail_pos.is_equal_approx(self_head):
		track._link_track_at_tail.call_deferred(self)
	
	track_at_head = track


func _link_track_at_tail(track: Track) -> void:
	if track_at_tail == track or !track:
		return
	
	var head_pos = track.head_marker.global_position.round()
	var tail_pos = track.tail_marker.global_position.round()
	var self_tail = tail_marker.global_position
	
	if head_pos.is_equal_approx(self_tail):
		
		track._link_track_at_head.call_deferred(self)
	elif tail_pos.is_equal_approx(self_tail):
		track._link_track_at_tail.call_deferred(self)
	
	track_at_tail = track


func change_bogie_to_track_at_head(bogie: Bogie, distance: float) -> void:
	if !track_at_head:
		bogie.emit_end_of_track(distance)
		return
	
	bogie.set_track(track_at_head)
	
	if track_at_head.track_at_tail == self:
		bogie.progress_ratio = 1
		bogie.progress += distance
	elif track_at_head.track_at_head == self:
		bogie.progress_ratio = 0
		bogie.progress += distance
		bogie.direction *= -1


func change_bogie_to_track_at_tail(bogie: Bogie, distance: float) -> void:
	if !track_at_tail:
		bogie.emit_end_of_track(distance)
		return
	
	bogie.set_track(track_at_tail)
	
	if track_at_tail.track_at_tail == self:
		bogie.progress_ratio = 1
		bogie.progress += distance
		bogie.direction *= -1
	elif track_at_tail.track_at_head == self:
		bogie.progress_ratio = 0
		bogie.progress += distance

