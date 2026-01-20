extends Path2D

@onready var _arrow_head:Sprite2D = $"../Arrow_Head";
var _car:Node2D;

var _last_pos:Vector2;
var _drawing:bool;

var _arrow_ready:bool;

signal Arrow_Complete;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	set_process(false);
	
	_last_pos = get_global_mouse_position();
	_arrow_head.hide();
	
	$"../../Terrain/Barricades_Start/Barricade".Start_Barricade_Clicked.connect(_SIGNAL_Start_Drawing);


func _process(_delta: float) -> void:
	
	if _drawing:
		
		if Input.is_action_just_released("Click"):
			_drawing = false;
			_arrow_ready = true;
			Arrow_Complete.emit();
			return;
	
		var mouse_pos:Vector2 = get_global_mouse_position();
		if mouse_pos.distance_to(_last_pos) > 5:
			
			_arrow_head.show();
			_arrow_head.position = mouse_pos;
			var direction = (mouse_pos - _last_pos).normalized();
			_arrow_head.rotation_degrees = rad_to_deg(direction.angle());
			
			_last_pos = mouse_pos;
			self.curve.add_point(_last_pos);
			$"../".points = self.curve.get_baked_points();
			
		return;
			
	# Remove Arrow Tail according to Progression
	
	elif _arrow_ready:
		
		var points:Array[Vector2];
		points.assign($"..".points);
		
		if points.size() <= 0:
			$"..".points = [];
			_arrow_ready = false;
			set_process(false);
			_arrow_head.hide();
			return;
		
		for point in points:
			if point.distance_to(_car.global_position) < 100:
				points.erase(point);
		
		$"..".points = points;


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Start_Drawing() -> void:
	_drawing = true;
	set_process(true);


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Assign_Car(car:Node2D) -> void:
	_car = car;
