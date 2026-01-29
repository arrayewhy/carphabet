extends Node2D

var _points:Array[Vector2];


func _ready() -> void:
	
	if self.get_child_count() <= 0:
		_points.push_back(self.global_position);
	else:
		for child in get_children():
			_points.push_back(child.global_position);


func Get_Points() -> Array[Vector2]:
	return _points;
