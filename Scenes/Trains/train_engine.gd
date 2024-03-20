extends TrainVehicle
class_name TrainEngine

const friction_coefficient = 0.1
const gravity = 9.8
const rolling_resistance_coefficient = 0.005
const air_resistance_coefficient = 0.1
const air_density = 1.0

@onready var control_button: Button = %ControlButton
@onready var slider_direction: VSlider = %Direction
@onready var slider_break: VSlider = %Break
@onready var slider_throttle: VSlider = %Throttle
@onready var ui: CanvasLayer = $UI
@onready var camera_2d: Camera2D = $Camera2D
@onready var smoke_emitter: GPUParticles2D = $SmokeEmitter

@export var max_force: float = 500
@export var break_power: float = 12
@export_range(0.0,1.0,0.1) var train_throttle: float = 0:
	set(value):
		train_throttle = clamp(value, 0, 1)
@export_range(0.0,1.0,0.1) var train_break: float = 0:
	set(value):
		train_break = clamp(value, 0, 1)
@export_range(-1.0,1.0,0.1) var train_direction: float = 0:
	set(value):
		train_direction = clamp(value, -1, 1)

var friction_force: float = 0
var speed_current: float = 0
var applied_force: float = 0
var target_force: float = 0
var last_cam: Camera2D
var current: bool = false


func _ready() -> void:
	front_bogie.moved.connect(back_bogie.move_as_follower)
	total_mass = mass
	_update_frictions()


func change_total_mass(delta_mass: float) -> void:
	towed_mass += delta_mass
	total_mass = mass + towed_mass
	towed_mass_changed.emit(delta_mass)
	_update_frictions()


func _process(delta: float) -> void:
	_update_speed(delta)
	_update_values()
	global_position = lerp(global_position, front_bogie.global_position,.9)
	look_at(back_bogie.global_position)


func _physics_process(delta):
	_updated_applied_force(delta)
	if speed_current != 0 or applied_force != 0:
		_update_speed(delta)


func _input(event: InputEvent) -> void:
	if !current:
		return
	
	if event.is_action_pressed("train_brake"):
		slider_break.value = 1
	
	if Input.is_action_just_pressed("train_cut_throttle"):
		slider_throttle.value = 0
	
	if Input.is_action_just_pressed("train_escape"):
		control_button.show()
		ui.hide()
		current = false
		camera_2d.enabled = false
		last_cam.enabled = true


func _updated_applied_force(delta):
	target_force = lerp(
		target_force,
		train_throttle * round(train_direction) if train_direction != 0 else \
		train_throttle,
		0.08
	)
	applied_force = lerp(applied_force, max_force * target_force, delta)
	if abs(applied_force) < 0.1:
		applied_force = 0


func _update_values() -> void:
	train_throttle = slider_throttle.value
	train_break = slider_break.value
	train_direction = slider_direction.value


func _apply_brake(delta):
	if speed_current == 0:
		return
	elif speed_current > 0:
		speed_current = max(speed_current - train_break * break_power * delta, 0)
	elif speed_current < 0:
		speed_current = min(speed_current + train_break * break_power * delta, 0)



func _update_speed(delta: float) -> void:
	var resistance = friction_force + _drag_force()
	if applied_force == 0 && abs(speed_current) < resistance / total_mass * delta:
		speed_current = 0
	else:
		if speed_current > 0:
			speed_current += ((applied_force - resistance) / total_mass * delta)
		elif speed_current < 0:
			speed_current += ((applied_force + resistance) / total_mass * delta)
		else:
			speed_current += (applied_force / total_mass * delta)
	smoke_emitter.process_material.initial_velocity_min = (speed_current / 3)
	smoke_emitter.process_material.initial_velocity_max = (speed_current / 2)
	_apply_brake(delta)
	front_bogie.move(speed_current * delta)


func _drag_force():
	return (air_resistance_coefficient * air_density * (pow(speed_current,2)/2))


func _update_frictions():
	friction_force = friction_coefficient * total_mass * gravity
	friction_force += rolling_resistance_coefficient * total_mass * gravity


func abrupt_stop(complete_stop: bool = true) -> void:
	slider_break.value = 1
	slider_throttle.value = 0
	if complete_stop:
		speed_current = min(25, speed_current)
	target_force = 0
	applied_force = 0


func _on_control_button_pressed() -> void:
	last_cam = get_viewport().get_camera_2d()
	last_cam.enabled = false
	camera_2d.enabled = true
	current = true
	control_button.hide()
	ui.show()
