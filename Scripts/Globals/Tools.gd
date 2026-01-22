extends Node


func _ready() -> void:
	set_process(false);


func _process(_delta: float) -> void:
	# Speed up time
	if Input.is_action_pressed("F12"):
		Engine.time_scale = 4;
	elif Input.is_action_just_released("F12"):
		Engine.time_scale = 1;
		set_process(false);


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("F12"):
		set_process(true);
