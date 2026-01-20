extends Node2D

const _car_prefab:PackedScene = preload("res://Prefabs/car.tscn");

signal Win(endPoint:Vector2);


func _ready() -> void:
	
	var car:Node2D = _car_prefab.instantiate();
	car.set_script(load("res://Scripts/car.gd"));
	car.position = $Start_Point.position;
	self.add_child(car);
	$Arrow/Path2D.Assign_Car(car);
	
	$Terrain/Barricade_End.End_Barricade_Reached.connect(_Win);


func _Win(endPoint:Vector2) -> void:
	$Arrow.hide();
	Win.emit(endPoint);
