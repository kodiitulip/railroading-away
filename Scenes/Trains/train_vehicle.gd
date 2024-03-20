extends Sprite2D
class_name TrainVehicle

signal towed_mass_changed

@export var wheel_distance: float = 64
@export var follow_distance: float = 24
@export var mass: float = 10

@export_group("Bogies")
@export var front_bogie: Bogie
@export var back_bogie: Bogie

var towed_mass: float
var total_mass: float


func _ready() -> void:
	front_bogie.moved.connect(back_bogie.move_as_follower)
	total_mass = mass


func _process(_delta: float) -> void:
	global_position = lerp(global_position, front_bogie.global_position,.9)
	look_at(back_bogie.global_position)


func set_on_track(track: Track, progress: float = 0) -> void:
	front_bogie.set_track(track)
	back_bogie.set_track(track)
	back_bogie.direction = front_bogie.direction
	back_bogie.follow(front_bogie, wheel_distance)
	front_bogie.move(progress)


func set_follower_car(vehicle: TrainVehicle) -> void:
	var length = wheel_distance + follow_distance
	var new_progress = front_bogie.progress - length
	vehicle.set_on_track(back_bogie.current_track, new_progress)
	vehicle.front_bogie.follow(back_bogie, follow_distance)
	back_bogie.moved.connect(vehicle.front_bogie.move_as_follower)
	vehicle.towed_mass_changed.connect(change_total_mass)
	change_total_mass(vehicle.total_mass)


func remove_follower_car(vehicle: TrainVehicle) -> void:
	back_bogie.moved.disconnect(vehicle.front_bogie.move_as_follower)
	vehicle.towed_mass_changed.disconnect(change_total_mass)
	change_total_mass(-vehicle.total_mass)


func change_total_mass(delta_mass: float) -> void:
	towed_mass += delta_mass
	total_mass = mass + towed_mass
	towed_mass_changed.emit(delta_mass)
