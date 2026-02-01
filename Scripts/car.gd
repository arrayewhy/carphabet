extends Node2D

var _arrow_path:Path2D;
var _arrow_path_follow:PathFollow2D;

@onready var _car_sprite_scale:Vector2 = $AnimatedSprite2D.scale;

const _speed:float = 200;

var _last_pos:Vector2;

var _move_along_route_tween:Tween;
var _car_distortion_tween:Tween;
var _car_wobble_tween:Tween;

signal Mouseover_Car(state:bool);
signal Arrived;
signal Crash;


func _ready() -> void:
	
	set_process(false);
	
	# Connect to Car Area Signals
	$Area2D.mouse_entered.connect(_SIGNAL_Mouseover_Car.bind(true));
	$Area2D.mouse_exited.connect(_SIGNAL_Mouseover_Car.bind(false));


func _process(delta: float) -> void:
	
	_arrow_path_follow.progress += _speed * delta;
	self.global_position = _arrow_path_follow.global_position;
	
	# Remove Arrow Path Tail
	#_arrow_path.Remove_Points_Around_Position(self.global_position);
	
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
		AudioMaster.Play_CarHorn();


func _SIGNAL_Start_Driving() -> void:
	set_process(true);
	_Wobble_Car_While_Driving();
	# Connect to detect crash zones here, after the car has been spawned to avoid colliding on spawn
	$Area2D.area_entered.connect(_SIGNAL_Crash);


func _SIGNAL_Crash(_area:Area2D) -> void:
	Crash.emit();
	self.modulate = Color.RED;
	set_process(false);


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
			_move_along_route_tween.chain().tween_property(self, "global_position", curr_point, duration);
		
		var direction:Vector2 = curr_point - self.global_position;
		direction = direction.normalized();
		
		# Animate Turn
		$AnimatedSprite2D.Animate(direction);
		
		await _move_along_route_tween.finished;






func _Car_Bounce() -> void:
	if _car_distortion_tween != null:
		_car_distortion_tween.kill();
	_car_distortion_tween = create_tween();
	_car_distortion_tween.tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(1.2, .8), .05);
	_car_distortion_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(.8, 1.2), .05);
	_car_distortion_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(1.05, .95), .05);
	_car_distortion_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale, .05);


func _Engine_Tremor() -> void:
	if _car_distortion_tween != null:
		_car_distortion_tween.kill();
	_car_distortion_tween = create_tween();
	_car_distortion_tween.tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(.975, 1.025), .05);
	_car_distortion_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(1, 1), .05);
	# Repeat the Tremor
	await _car_distortion_tween.finished;
	_Engine_Tremor();


func _Wobble_Car_While_Driving() -> void:
	
	if _car_wobble_tween != null:
		_car_wobble_tween.kill();
		
	_car_wobble_tween = create_tween();
	_car_wobble_tween.tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(.95, 1.05), .1);
	_car_wobble_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(1.05, .95), .1);
	
	await _car_wobble_tween.finished;
	
	if is_processing():
		_Wobble_Car_While_Driving();
	else:
		_car_wobble_tween.kill();
		_car_wobble_tween = create_tween();
		_car_wobble_tween.tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(.95, 1.05), .2);
		_car_wobble_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale, .3);
