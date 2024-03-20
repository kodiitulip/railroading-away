extends Node2D

@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	$Tracks/TrainDepot._link_track_at_tail($Tracks/TrackSwitch3/LeftTrack)
	$Tracks/Track._link_track_at_tail($Tracks/TrackSwitch3/RightTrack)
	$Tracks/Track2._link_track_at_head($Tracks/TrackSwitch3/MainTrack)
	$Tracks/Track2._link_track_at_tail($Tracks/Track3)
	$Tracks/Track3._link_track_at_head($Tracks/TrackSwitch/MainTrack)
	$Tracks/TrackSwitch/RightTrack._link_track_at_tail($Tracks/Track5)
	$Tracks/TrackSwitch/LeftTrack._link_track_at_tail($Tracks/Track4)
	$Tracks/Track5._link_track_at_tail($Tracks/TrackSwitch2/RightTrack)
	$Tracks/TrackSwitch2/LeftTrack._link_track_at_tail($Tracks/Track4)
	$Tracks/Track._link_track_at_head($Tracks/TrackSwitch2/MainTrack)
	
