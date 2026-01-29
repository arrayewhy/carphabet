@icon("res://Misc/Icons/bars_icon_red.png")

extends Area2D

@export var _changes:Dictionary[int, Array];


func _ready() -> void:
	$"..".Activate_Car.connect(_SIGNAL_Toggle_Areas);


func _SIGNAL_Toggle_Areas(curr_car:int) -> void:
	
	var targ_changes:int = curr_car - 1;
	var targ_col_shape_paths:Array = _changes[targ_changes];
	
	for path in targ_col_shape_paths:
		
		# TEMPORARY: Not sure how assign col_shape with an Explicit Type
		# when I don't know if the current collision is a Shape or Polygon
		var col_shape = get_node(path);
		
		col_shape.disabled = !col_shape.disabled;
		
		if col_shape.disabled:
			col_shape.hide();
		else:
			col_shape.show();
