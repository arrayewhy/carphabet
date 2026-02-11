extends Path2D

var _can_draw:bool;

var _mouse_move_thresh:float = 50;
var _last_mouse_pos:Vector2;
var _last_dir:Vector2 = Vector2.INF;

var _lines:Array[Line2D];
var _curr_line_idx:int;

var _completed:bool;

signal Path_Complete;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	set_process(false);
	$Arrow_Head.hide();
	
	_lines.push_back($Line2D);


func _process(_delta: float) -> void:
	
	var curr_mouse_pos:Vector2 = get_global_mouse_position();
	
	# Automatically End path Drawing when Cursor is near End point
	#if curr_mouse_pos.distance_to($"..".Get_End_Point()) <= 10:
		#_can_draw = false;
		#set_process(false);
		#Path_Complete.emit();
		## Disconnect Signals
		#Tools.Disconnect_Callables(Path_Complete);
		#$"..".Get_Curr_Car().Mouseover_Car.disconnect(_SIGNAL_Set_Can_Draw);
		#return;
	
	if curr_mouse_pos.distance_to(_last_mouse_pos) > _mouse_move_thresh:
		if $"../Debug_Sprite" != null: $"../Debug_Sprite".global_position = curr_mouse_pos;
		self.curve.add_point(curr_mouse_pos);
		# Update Arrow Head Rotation
		var direction = _last_mouse_pos.direction_to(curr_mouse_pos);
		
		if direction.dot(_last_dir) <= 0.3:
			#print('New Line')
			var new_line:Line2D = _lines[_curr_line_idx].duplicate();
			
			new_line.clear_points();
			#self.curve.clear_points();
			
			_lines.push_back(new_line);
			self.add_child(new_line);
			_curr_line_idx += 1;
		
		_last_dir = direction;
		$Arrow_Head.rotation_degrees = rad_to_deg(direction.angle());
		$Arrow_Head.global_position = curr_mouse_pos;
		if !$Arrow_Head.visible:
			$Arrow_Head.show();
		# Update Arrow Line
		_lines[_curr_line_idx].points = self.curve.get_baked_points();
		_last_mouse_pos = curr_mouse_pos;
		# Sound
		AudioMaster.Play_Stone_Clack();


func _input(event: InputEvent) -> void:
	
	if _completed:
		return;
	
	#if event.is_action_pressed("Click") && _can_draw:
	if event.is_action("Click") && $"..".Get_Curr_Car().global_position.distance_to(get_global_mouse_position()) <= 50:
		
		_last_mouse_pos = get_global_mouse_position();
		self.curve.add_point(_last_mouse_pos);
		
		set_process(true);
		$"..".Get_Curr_Car().modulate = Color.GREEN;
		return;
	
	if event.is_action_released("Click") && is_processing():
		
		_can_draw = false;
		
		set_process(false);
		$"..".Get_Curr_Car().modulate = Color.RED;
		# If the Path is too Short,
		# Reset it and wait to draw again.
		if self.curve.point_count <= 5:
			Reset();
			return;
		
		Path_Complete.emit();
		Tools.Disconnect_Callables(Path_Complete);
		
		_completed = true;
		
		#$"..".Get_Curr_Car().Mouseover_Car.disconnect(_SIGNAL_Set_Can_Draw);


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


#func _SIGNAL_Set_Can_Draw(state:bool) -> void:
	#_can_draw = state;


func _SIGNAL_Reset_Arrow() -> void:
	Reset();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Reset() -> void:
	self.curve.clear_points();
	_lines[_curr_line_idx].clear_points();
	$Arrow_Head.hide();


#func Connect_To_Car(car:Node2D) -> void:
	#car.Mouseover_Car.connect(_SIGNAL_Set_Can_Draw);


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Get_PathFollow() -> PathFollow2D:
	return $PathFollow2D;
