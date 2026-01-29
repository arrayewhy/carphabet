extends Node2D

var _hovering:bool;

var _spr_array:Array[Sprite2D];


func _ready() -> void:
	
	# Record all Children as Sprite2Ds except
	# for the Last one which should be an Area2D.
	for i in self.get_child_count():
		if i < self.get_child_count() - 1:
			_spr_array.push_back(self.get_child(i));
	
	$Area2D.mouse_entered.connect(_Hover);
	$Area2D.mouse_exited.connect(_Hover);


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("Click") && _hovering:
		
		_hovering = false;
		
		$Area2D.mouse_entered.disconnect(_Hover);
		$Area2D.mouse_exited.disconnect(_Hover);
		
		$Area2D.monitorable = false;
		
		_spr_array[0].hide();
		_spr_array[1].show();


func _Hover() -> void:
	_hovering = !_hovering;
