extends AnimatedSprite2D

enum BARR_TYPE { IN, OUT }

@export var _type:BARR_TYPE;

var _can_start:bool;
var _started:bool;

signal Start_Barricade_Clicked;
signal End_Barricade_Reached(endPoint:Vector2);


func _ready() -> void:
	
	$Area2D.area_entered.connect(_SIGNAL_Car_Enter);
	$Area2D.area_exited.connect(_SIGNAL_Car_Exit);
	
	$Area2D.mouse_entered.connect(_SIGNAL_Mouse_Enter);
	$Area2D.mouse_exited.connect(_SIGNAL_Mouse_Exit);


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Click") && !_started:
		if _can_start:
			_started = true;
			Start_Barricade_Clicked.emit();


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Car_Enter(area:Area2D) -> void:
	
	if area.get_parent().name.contains("Car"):
		# Signal Level Completion
		if _type == BARR_TYPE.OUT:
			End_Barricade_Reached.emit($Node2D.global_position);
			area.get_parent().Standby();
		# Animate Barricade
		_Animate_Open();

func _SIGNAL_Car_Exit(area:Area2D) -> void:
	# Animate Barricade
	if area.get_parent().name == "Car":
		_Animate_Closed();


func _SIGNAL_Mouse_Enter() -> void:
	if !_started:
		_can_start = true;
	_Animate_Open();

func _SIGNAL_Mouse_Exit() -> void:
	if !_started:
		_can_start = false;
	_Animate_Closed();


# Functions: Animation ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

func _Animate_Open() -> void:
	play("Open");

func _Animate_Closed() -> void:
	play("Closed");
