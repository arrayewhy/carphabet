extends Node2D

var _arrow_path:Path2D;
var _arrow_path_follow:PathFollow2D;

@onready var _car_sprite_scale:Vector2 = $AnimatedSprite2D.scale;

const _speed:float = 300;

var _last_pos:Vector2;

var _move_along_route_tween:Tween;
var _bounce_tween:Tween;
var _tremor_tween:Tween;
var _driving_wobble_tween:Tween;

signal Mouseover_Car(state:bool);
signal Arrived;
signal Accident;


func _ready() -> void:
	
	set_process(false);
	
	# Connect to Car Area Signals
	$Area2D.mouse_entered.connect(_SIGNAL_Mouseover_Car.bind(true));
	$Area2D.mouse_exited.connect(_SIGNAL_Mouseover_Car.bind(false));
	
	# Start Engine Animation Loop
	_Engine_Tremor();
	# Start Engine Sound Loop
	AudioMaster.Play_Car_Engine_Idle();


func _process(delta: float) -> void:
	
	_arrow_path_follow.progress = _arrow_path_follow.progress + _speed * delta;
	
	# If the End of the path is Reached Before Arriving at an end point,
	# Restart.
	if _arrow_path_follow.progress_ratio >= 1:
		self.set_process(false);
		_Play_Accident_Animation();
		# Sound
		AudioMaster.Play_Tyre_Screech();
		Accident.emit();
		return;
	
	# Position the car at the 'head' of the Arrow's PathFollow object.
	self.global_position = _arrow_path_follow.global_position;
	
	var direction:Vector2 = self.global_position - _last_pos;
	direction = direction.normalized();
	_last_pos = self.global_position;
	
	# Animation
	$AnimatedSprite2D.Animate(direction);
	
	# Stop Car at the End Point
	var end_point:Vector2 = $"../..".Get_End_Point();
	if end_point.distance_to(self.global_position) <= 50:
		
		# We Disable Crash Detection here so that
		# the car does not crash into anything on its End Route.
		$Area2D.area_entered.disconnect(_SIGNAL_Crash);
		
		set_process(false);
		
		# Move Car along End Route
		var route:Array[Vector2] = $"../..".Get_End_Route();
		
		if route.size() <= 1:
			self.global_position = route[0];
		else:
			Move_Car_Along_Route(route);
			await _move_along_route_tween.finished;
		
		# When the car is at its End Point,
		# Delay briefly before Signalling that it has Arrived.
		await get_tree().create_timer(1).timeout;
		
		Arrived.emit();
		
		Tools.Disconnect_Callables(Mouseover_Car);
		Tools.Disconnect_Callables(Arrived);
		
		_arrow_path_follow.progress = 0;


func _SIGNAL_Mouseover_Car(state:bool) -> void:
	Mouseover_Car.emit(state);
	if state == true:
		_Car_Bounce();
		AudioMaster.Play_Car_Horn();


func _SIGNAL_Start_Driving() -> void:
	set_process(true);
	_Wobble_Car_While_Driving();
	# Connect to detect crash zones here, after the car has been spawned to avoid colliding on spawn
	$Area2D.area_entered.connect(_SIGNAL_Crash);


func _SIGNAL_Crash(_area:Area2D) -> void:
	
	# Stop Movement Operations
	set_process(false);
	
	_Play_Accident_Animation();
	# Sound
	AudioMaster.Play_Metal_Bang();
	
	Accident.emit();


func _Play_Accident_Animation() -> void:
	# Crash Animation
	_tremor_tween.kill();
	_Car_Bounce();


func Connect_To_Arrow(arrow:Line2D) -> void:
	_arrow_path = arrow.get_child(0);
	_arrow_path_follow = _arrow_path.get_child(0);
	_arrow_path.Path_Complete.connect(_SIGNAL_Start_Driving);


func Move_Car_Along_Route(points:Array[Vector2]) -> void:
	
	self.global_position = points[0];
	
	for i in points.size() - 1:
		
		if _move_along_route_tween != null:
			_move_along_route_tween.kill();
		_move_along_route_tween = create_tween();
		
		var curr_point:Vector2 = points[i + 1];
		var duration:float = self.global_position.distance_to(curr_point) / (_speed * 2);
		
		if i == 0:
			_move_along_route_tween.tween_property(self, "global_position", curr_point, duration);
		else:
			_move_along_route_tween.tween_property(self, "global_position", curr_point, duration);
		
		var direction:Vector2 = curr_point - self.global_position;
		direction = direction.normalized();
		
		# Animate Turn
		$AnimatedSprite2D.Animate(direction);
		
		await _move_along_route_tween.finished;






func _Car_Bounce() -> void:
	if _bounce_tween != null:
		_bounce_tween.kill();
	_bounce_tween = create_tween();
	_bounce_tween.tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(1.2, .8), .05);
	_bounce_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(.8, 1.2), .05);
	_bounce_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(1.05, .95), .05);
	_bounce_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale, .05);


func _Engine_Tremor() -> void:
	if _tremor_tween != null:
		_tremor_tween.kill();
	_tremor_tween = create_tween();
	_tremor_tween.tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(.975, 1.025), .05);
	_tremor_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(1, 1), .05);
	# Repeat the Tremor
	await _tremor_tween.finished;
	_Engine_Tremor();


func _Wobble_Car_While_Driving() -> void:
	
	if _driving_wobble_tween != null:
		_driving_wobble_tween.kill();
		
	_driving_wobble_tween = create_tween();
	_driving_wobble_tween.tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(.95, 1.05), .1);
	_driving_wobble_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(1.05, .95), .1);
	
	await _driving_wobble_tween.finished;
	
	if is_processing():
		_Wobble_Car_While_Driving();
	else:
		_driving_wobble_tween.kill();
		_driving_wobble_tween = create_tween();
		_driving_wobble_tween.tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(.95, 1.05), .2);
		_driving_wobble_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale, .3);
