@tool
extends Track
class_name TrainDepot

const train_engine: PackedScene = preload("res://Scenes/Trains/train_engine.tscn")
const train_vehicle: PackedScene = preload("res://Scenes/Trains/train_vehicle.tscn")

@onready var button: Button = $ColorRect/Button


func _on_button_pressed() -> void:
	if self.busy:
		return
	
	var engine: TrainVehicle = train_engine.instantiate()
	add_child(engine)
	engine.set_on_track(self, 354)
	var last_car: TrainVehicle = engine
	for i in range(3):
		var car = train_vehicle.instantiate()
		add_child(car)
		last_car.set_follower_car(car)
		last_car = car

