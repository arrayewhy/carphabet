@icon("res://Misc/Icons/bars_icon_red.png")
extends Node2D

var _hovering:bool;

var _spr_array:Array[Sprite2D];

@export var _touch_sounds:Array[AudioMaster.SOUND_TYPE];
@export var _col_sounds:Array[AudioMaster.SOUND_TYPE];


func _ready() -> void:
	
	# Record all Children as Sprite2Ds except
	# for the Last one which should be an Area2D.
	for i in self.get_child_count() - 1:
		_spr_array.push_back(self.get_child(i));
	
	$Area2D.mouse_entered.connect(_Hover);
	$Area2D.mouse_exited.connect(_Hover);
	
	$Area2D.area_entered.connect(_SIGNAL_Play_Collision_Sounds);


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Click") && _hovering:
		
		_hovering = false;
		
		$Area2D.mouse_entered.disconnect(_Hover);
		$Area2D.mouse_exited.disconnect(_Hover);
		
		$Area2D.area_entered.disconnect(_SIGNAL_Play_Collision_Sounds);
		
		$Area2D.monitorable = false;
		
		_spr_array[0].hide();
		_spr_array[1].show();
		
		# Sound
		
		for sound in _touch_sounds:
			AudioMaster.Play_By_Sound_Type(sound);


func _Hover() -> void:
	_hovering = !_hovering;


func _SIGNAL_Play_Collision_Sounds(area:Area2D) -> void:
	# TEMPORARY
	if !area.get_parent().name.contains("Car"):
		return;
	for sound in _col_sounds:
		AudioMaster.Play_By_Sound_Type(sound);
