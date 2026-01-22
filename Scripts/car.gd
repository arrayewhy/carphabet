extends Node2D

@onready var _arrow_path:Path2D = $"../Arrow/Path2D";
@onready var _arrow_path_follow:PathFollow2D = $"../Arrow/Path2D/PathFollow2D";

const _speed:float = 200;
@onready var _car_sprite_scale:Vector2 = $AnimatedSprite2D.scale;

var _car_idx:int;

var _driving:bool;
var _last_pos:Vector2;

var _distortion_tween:Tween;
var _wobble_tween:Tween;

var _mouse_on:bool;

signal Car_Clicked;
signal Car_Stopped();


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	set_process(false);
	
	_arrow_path_follow.loop = false;
	_arrow_path_follow.rotates = false;
	
	$Area2D.area_entered.connect(_Contact);
	$Area2D.mouse_entered.connect(_SIGNAL_Boop_Car);
	$Area2D.mouse_entered.connect(_SIGNAL_Mouse_On);
	$Area2D.mouse_exited.connect(_SIGNAL_Mouse_Off);
	
	$"..".Move_Car_To_End.connect(_Move_To_EndPoint);
	
	_Engine_Tremor();


func _process(delta: float) -> void:
	
	_arrow_path_follow.progress += delta * _speed;
	self.global_position = _arrow_path_follow.global_position;
	var direction:Vector2 = self.global_position - _last_pos;
	direction = direction.normalized();
	_last_pos = self.global_position;
	
	# Animation
	$AnimatedSprite2D.Animate(direction);


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Click") && _mouse_on:
		_mouse_on = false;
		Car_Clicked.emit();
		$Area2D.mouse_entered.disconnect(_SIGNAL_Mouse_On);
		$Area2D.mouse_exited.disconnect(_SIGNAL_Mouse_Off);


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Boop_Car() -> void:
	# Animate Car on Mouseover
	if _distortion_tween != null:
		_distortion_tween.kill();
	_distortion_tween = create_tween();
	_distortion_tween.tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(1.2, .8), .05);
	_distortion_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(.8, 1.2), .05);
	_distortion_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(1.05, .95), .05);
	_distortion_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale, .05);
	# Play Car Horn
	AudioMaster.Play_CarHorn(true);
	# Resume the Engine Tremor
	await _distortion_tween.finished;
	_Engine_Tremor();


func _SIGNAL_Start_Driving() -> void:
	_last_pos = self.global_position;
	set_process(true);
	_driving = true;
	_Driving_Wobble();


func _SIGNAL_Mouse_On() -> void:
	_mouse_on = true;

func _SIGNAL_Mouse_Off() -> void:
	_mouse_on = false;


func Assign_To_Arrow_Path() -> void:
	_arrow_path.Arrow_Complete.connect(_SIGNAL_Start_Driving);


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Contact(area:Area2D) -> void:
	match area.name:
		"Crash_Zone":
			print("Bang!");
			_driving = false;


func Set_Car_Idx(idx:int) -> void:
	_car_idx = idx;


func Standby() -> void:
	set_process(false);
	_arrow_path_follow.progress = 0;
	_arrow_path.Arrow_Complete.disconnect(_SIGNAL_Start_Driving);


func _Engine_Tremor() -> void:
	
	if _distortion_tween != null:
		_distortion_tween.kill();
	_distortion_tween = create_tween();
	_distortion_tween.tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(.975, 1.025), .05);
	_distortion_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(1, 1), .05);
	# Repeat the Tremor
	await _distortion_tween.finished;
	_Engine_Tremor();


func _Driving_Wobble() -> void:
	
	if _wobble_tween != null:
		_wobble_tween.kill();
		
	_wobble_tween = create_tween();
	_wobble_tween.tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(.95, 1.05), .1);
	_wobble_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(1.05, .95), .1);
	
	await _wobble_tween.finished;
	
	if _driving:
		_Driving_Wobble();
	else:
		_wobble_tween.kill();
		_wobble_tween = create_tween();
		_wobble_tween.tween_property($AnimatedSprite2D, "scale", _car_sprite_scale * Vector2(.95, 1.05), .2);
		_wobble_tween.chain().tween_property($AnimatedSprite2D, "scale", _car_sprite_scale, .3);


func _Move_To_EndPoint(car_idx:int, endPoint:Vector2) -> void:

	if car_idx != _car_idx:
		return;

	set_process(false);
	
	$AnimatedSprite2D.Animate((endPoint - global_position).normalized());
	
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_QUAD);
	tween.set_ease(Tween.EASE_OUT);
	tween.tween_property(self, "global_position", endPoint, 2);
	
	await tween.finished;
	
	_driving = false;
	
	await get_tree().create_timer(2).timeout;

	Car_Stopped.emit();
