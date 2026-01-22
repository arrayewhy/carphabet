extends Path2D

@onready var _arrow_head:Sprite2D = $"../Arrow_Head";
var _car:Node2D;

var _last_mouse_pos:Vector2;
var _drawing:bool;

var _arrow_ready:bool;

signal Arrow_Complete;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	set_process(false);
	
	_last_mouse_pos = get_global_mouse_position();
	
	$"..".clear_points();
	_arrow_head.hide();
	
	#await get_tree().process_frame;
	
	#$"../../Car".Car_Clicked.connect(_SIGNAL_Start_Drawing);


func _process(_delta: float) -> void:
	
	if _drawing:
		
		if Input.is_action_just_released("Click"):
			_drawing = false;
			_arrow_ready = true;
			Arrow_Complete.emit();
			return;
	
		var mouse_pos:Vector2 = get_global_mouse_position();
		if mouse_pos.distance_to(_last_mouse_pos) > 5:
			
			_arrow_head.show();
			_arrow_head.position = mouse_pos;
			var direction = (mouse_pos - _last_mouse_pos).normalized();
			_arrow_head.rotation_degrees = rad_to_deg(direction.angle());
			
			_last_mouse_pos = mouse_pos;
			self.curve.add_point(_last_mouse_pos);
			$"../".points = self.curve.get_baked_points();
			
		return;
			
	# Remove Arrow Tail according to Progression
	
	elif _arrow_ready:
		
		var arrow_line_points:Array[Vector2];
		
		# We use 'assign()' instead of 'arrow_line_points = $"..".points'
		# because '$"..".points' gives a PackedVector2 Array instead of
		# the expected Array[Vector2]. These are not the same thing, apparently...
		arrow_line_points.assign($"..".points);
		
		if arrow_line_points.size() <= 0:
			$"..".clear_points();
			_arrow_ready = false;
			set_process(false);
			_arrow_head.hide();
			return;
		
		for point in arrow_line_points:
			if point.distance_to(_car.global_position) < 100:
				arrow_line_points.erase(point);
		
		$"..".points = arrow_line_points;


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Start_Drawing() -> void:
	_drawing = true;
	set_process(true);
	print("Draw");


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Assign_Car(car:Node2D) -> void:
	
	if _car != null:
		self.curve.clear_points();
		$"../".clear_points();
		_car.Car_Clicked.disconnect(_SIGNAL_Start_Drawing);
	
	_car = car;
	_car.Car_Clicked.connect(_SIGNAL_Start_Drawing);
	print('Active Car: ', _car._car_idx);
