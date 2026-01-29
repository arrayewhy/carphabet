extends Node2D

@export var _curr_scene:Globals.SceneType;

const _car_prefab:PackedScene = preload("res://Prefabs/car.tscn");

var _curr_car_idx;

signal Activate_Car;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	Globals.CURRENT_SCENE_TYPE = _curr_scene;
	
	_curr_car_idx = 0;
	
	# Spawn New Car and run its Configurations
	var car:Node2D = _Create_And_Connect_Car_Then_Move_Along_Route();
	
	$"Environment".add_child(car);
	
	# Create the Car Holder
	#var car_holder:Node2D = Node2D.new();
	#car_holder.name = "Car_Holder";
	#car_holder.add_child(car);
	#
	#self.add_child(car_holder);


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Check_Next_Step() -> void:
	
	_curr_car_idx += 1;
	
	if _curr_car_idx >= $Start_Routes.get_child_count():
		# Proceed to Next Level
		print("Next!");
	else:
		# Prepare Next Car
		var car:Node2D = _Create_And_Connect_Car_Then_Move_Along_Route();
		
		$"Environment".add_child(car);
		
		Activate_Car.emit(_curr_car_idx);


func _SIGNAL_Restart() -> void:
	await get_tree().create_timer(1).timeout;
	$Arrow/Path2D.Reset();
	Globals._Reload_Current_Scene();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Create_And_Connect_Car_Then_Move_Along_Route() -> Node2D:
	var car:Node2D = _car_prefab.instantiate();
	car.set_script(load("res://Scripts/car.gd"));
	car.Move_Car_Along_Route(_Get_Start_Route());
	car.Arrived.connect(_SIGNAL_Check_Next_Step);
	car.Crash.connect(_SIGNAL_Restart);
	$Arrow/Path2D.Connect_To_Car(car);
	return car;


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Get_Start_Point() -> Vector2:
	return _Get_Start_Route()[0];

func _Get_Start_Route() -> Array[Vector2]:
	return $Start_Routes.get_child(_curr_car_idx).Get_Points();


func Get_End_Point() -> Vector2:
	return Get_End_Route()[0];

func Get_End_Route() -> Array[Vector2]:
	if _curr_car_idx < $End_Routes.get_child_count():
		return $End_Routes.get_child(_curr_car_idx).Get_Points();
	else:
		return $End_Routes.get_child(0).Get_Points();
