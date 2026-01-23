extends Node2D

const _car_prefab:PackedScene = preload("res://Prefabs/car.tscn");

@export var _scene_type:Globals.SceneType;

var _cars:Array[Node2D];
var _routes_completed:int;

signal Move_Car_To_End(car_idx:int, endPoint:Vector2);


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	var car_tween:Tween
	
	var start_barricades:Array[Node] = $"Terrain/Barricades_Start".get_children();
	
	for i in start_barricades.size():
		# Create Car
		var car:Node2D = _car_prefab.instantiate();
		car.name = "Car" + str(i);
		car.set_script(load("res://Scripts/car.gd"));
		car.Set_Car_Idx(i);
		_cars.append(car);
		self.add_child(car);
		
		if i <= 0:
		
			var start_point_nodes:Array[Node] = start_barricades[i].get_node("Points").get_children();
			
			if start_point_nodes.size() <= 1:
				car.global_position = start_point_nodes[0].global_position;
			else:
				
				# Create Route
				var route_points:Array[Vector2];
				for point in start_point_nodes:
					route_points.append(point.global_position);
				
				# Position Car to First Point
				car.global_position = route_points[0];
				
				# Move Car
				car_tween = create_tween();
				
				for r in route_points.size() - 1:
					var dist:float = car.global_position.distance_to(route_points[r + 1]);
					if i <= 0:
						car_tween.tween_property(car, "global_position", route_points[r + 1], dist / car._speed);
					else:
						car_tween.chain().tween_property(car, "global_position", route_points[r + 1], dist / car._speed);
			
		elif i > 0:
			
			car.global_position = start_barricades[i].get_node("Points").get_child(0).global_position;
		
		car.Car_Stopped.connect(_SIGNAL_Check_Prog_Next_Scene);
	
	$Terrain/Barricades_End/Barricade.End_Barricade_Reached.connect(_Check_Car_On_Barricade_Entry);
	
	if car_tween != null:
		await car_tween.finished;

	# After the First Car is done moving in,
	# prepare for Path Drawing.
	$Arrow/Path2D.Assign_Car(_cars[0]);
	_cars[0].Assign_To_Arrow_Path();
	
	Globals.CURRENT_SCENE_TYPE = _scene_type;


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Check_Prog_Next_Scene() -> void:
	if _routes_completed == $Terrain/Barricades_Start.get_child_count() - 1:
		Globals.Progress_To_Next_Scene();
	else:
		_routes_completed += 1;
		var next_car:int = _routes_completed;
		$Arrow/Path2D.Assign_Car(_cars[next_car]);
		_cars[next_car].Assign_To_Arrow_Path();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Check_Car_On_Barricade_Entry(endPoint:Vector2) -> void:
	var car_idx:int = _routes_completed;
	Move_Car_To_End.emit(car_idx, endPoint);
