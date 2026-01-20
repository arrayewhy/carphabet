@tool
extends Line2D

@export var _update_road:bool;


func _ready() -> void:
	if Engine.is_editor_hint():
		_Update_Points();


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if _update_road:
			_update_road = false;
			_Update_Points();


func _Update_Points() -> void:
	self.points = $Path2D.curve.get_baked_points();
