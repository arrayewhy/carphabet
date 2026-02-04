extends Path2D

var _can_draw:bool;

var _mouse_move_thresh:float = 50;
var _last_mouse_pos:Vector2;
var _last_dir:Vector2 = Vector2.INF;

signal Path_Complete;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	set_process(false);
	$"../Arrow_Head".hide();


func _process(_delta: float) -> void:
	
	var curr_mouse_pos:Vector2 = get_global_mouse_position();
	
	if curr_mouse_pos.distance_to(_last_mouse_pos) > _mouse_move_thresh:
		self.curve.add_point(curr_mouse_pos);
		# Update Arrow Head Rotation
		var direction = _last_mouse_pos.direction_to(curr_mouse_pos);
		print(direction.dot(_last_dir))
		_last_dir = direction;
		$"../Arrow_Head".rotation_degrees = rad_to_deg(direction.angle());
		$"../Arrow_Head".global_position = curr_mouse_pos;
		if !$"../Arrow_Head".visible:
			$"../Arrow_Head".show();
		# Update Arrow Line
		$"..".points = self.curve.get_baked_points();
		_last_mouse_pos = curr_mouse_pos;
		# Sound
		AudioMaster.Play_Stone_Clack();


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Click") && _can_draw:
		
		_last_mouse_pos = get_global_mouse_position();
		self.curve.add_point(_last_mouse_pos);
		
		set_process(true);
		
		return;
	
	if event.is_action_released("Click") && is_processing():
		
		_can_draw = false;
		
		set_process(false);
		
		Path_Complete.emit();
		Tools.Disconnect_Callables(Path_Complete);
		
		$"../..".Get_Curr_Car().Mouseover_Car.disconnect(_SIGNAL_Set_Can_Draw);


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Set_Can_Draw(state:bool) -> void:
	_can_draw = state;


func _SIGNAL_Reset_Arrow() -> void:
	Reset();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Reset() -> void:
	self.curve.clear_points();
	$"..".clear_points();
	$"../Arrow_Head".hide();


func Connect_To_Car(car:Node2D) -> void:
	car.Mouseover_Car.connect(_SIGNAL_Set_Can_Draw);
	#car.Arrived.connect(_SIGNAL_Reset_Arrow);


func Remove_Points_Around_Position(global_pos:Vector2) -> void:
	
	var arrow_line_points:Array[Vector2];
	arrow_line_points.assign($"..".points);
	
	var first_close_point_found:bool;
	
	for point in arrow_line_points:
		if point.distance_to(global_pos) <= 50:
			arrow_line_points.erase(point);
			if !first_close_point_found:
				first_close_point_found = true;
		else:
			if first_close_point_found:
				break;
	
	$"..".points = arrow_line_points;
