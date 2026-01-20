extends Node2D

const _car_prefab:PackedScene = preload("res://Prefabs/car.tscn");

@export var _scene_type:Globals.SceneType;

signal Win(endPoint:Vector2);


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	var car:Node2D = _car_prefab.instantiate();
	car.set_script(load("res://Scripts/car.gd"));
	car.position = $Terrain/Barricades_Start/Barricade/Node2D.global_position;
	self.add_child(car);
	
	$Arrow/Path2D.Assign_Car(car);
	
	$Car.Car_Stopped.connect(_SIGNAL_Progress_To_Next_Scene);
	$Terrain/Barricades_End/Barricade.End_Barricade_Reached.connect(_Win);
	
	Globals.CURRENT_SCENE_TYPE = _scene_type;


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Progress_To_Next_Scene() -> void:
	Globals.Progress_To_Next_Scene();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Win(endPoint:Vector2) -> void:
	$Arrow.hide();
	Win.emit(endPoint);
