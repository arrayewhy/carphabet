extends Node2D

@export var _curr_scene:Globals.SceneType;

const _car_prefab:PackedScene = preload("res://Prefabs/car.tscn");
const _arrow_prefab:PackedScene = preload("res://Prefabs/arrow.tscn");

var _cars:Array[Node2D];
var _curr_car_idx:int;
var _curr_arrow:Line2D;

signal Activate_Car;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	Globals.CURRENT_SCENE_TYPE = _curr_scene;
	
	_curr_car_idx = 0;
	
	_curr_arrow = _arrow_prefab.instantiate();
	self.add_child(_curr_arrow);
	
	# Spawn New Car and run its Configurations
	var car:Node2D = _Create_And_Connect_Car_Then_Move_Along_Route();
	_cars.push_back(car);
	
	$"Environment".add_child(car);
	
	car.Move_Car_Along_Route(_Get_Start_Route());
	
	Curtain.Reveal();
	
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
		
		Curtain.Obscure();
		AudioMaster.Fade_All_Sounds_Out();
		
		# Wait for all Sounds to Stop playing.
		# Not the safest code, but it works as long as
		# the Curtain Fades out Faster.
		await AudioMaster.Silenced;
		
		_curr_arrow.get_child(0).Reset();
		
		Globals.Progress_To_Next_Scene();
		
	else:
		
		# Spawn a new Arrow to draw with so we Don't Disturb the previous one.
		# Do this Before spawning the Car because the car has to connect to it.
		_curr_arrow = _arrow_prefab.instantiate();
		# TEMPORARY
		# Instantiated objects seem to Retain Data
		# from previous instantiated copies, so we Force a Reset here.
		_curr_arrow.get_child(0).Reset();
		self.add_child(_curr_arrow);
		
		# Prepare Next Car
		var car:Node2D = _Create_And_Connect_Car_Then_Move_Along_Route();
		_cars.push_back(car);
		
		$"Environment".add_child(car);
		
		Activate_Car.emit(_curr_car_idx);
		
		car.Move_Car_Along_Route(_Get_Start_Route());


func _SIGNAL_Restart() -> void:
	
	await get_tree().create_timer(1).timeout;
	
	Curtain.Obscure();
	AudioMaster.Fade_All_Sounds_Out();
	
	# Wait for all Sounds to Stop playing.
	# Not the safest code, but it works as long as
	# the Curtain Fades out Faster.
	await AudioMaster.Silenced;
	
	_curr_arrow.get_child(0).Reset();
	
	Globals._Reload_Current_Scene();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Create_And_Connect_Car_Then_Move_Along_Route() -> Node2D:
	var car:Node2D = _car_prefab.instantiate();
	car.set_script(load("res://Scripts/car.gd"));
	car.Connect_To_Arrow(_curr_arrow);
	#car.Move_Car_Along_Route(_Get_Start_Route());
	car.Arrived.connect(_SIGNAL_Check_Next_Step);
	car.Accident.connect(_SIGNAL_Restart);
	_curr_arrow.get_child(0).Connect_To_Car(car);
	return car;


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Get_Curr_Car() -> Node2D:
	return _cars[_curr_car_idx];


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
