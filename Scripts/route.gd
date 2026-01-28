@tool
extends Node2D

@export var _assign_or_visualise:bool;
@export_multiline var _tip:String;

var _points:Array[Vector2];


func _init() -> void:
	if Engine.is_editor_hint():
		if _points.size() <= 0:
			_tip = str("No points assigned yet. \n", 
			"Click on 'Assign or Visualise' to either save child nodes as points", 
			"or visualise existing points as nodes.");


func _ready() -> void:
	if _points.size() <= 0:
		_points.push_back(self.global_position);


func _process(_delta: float) -> void:
	
	if Engine.is_editor_hint():
		
		if _assign_or_visualise:
			_assign_or_visualise = false;
			
			# Create a child node for each Point
			if self.get_child_count() == 0:
				
				for i in _points.size():
					var node:Node2D = Sprite2D.new();
					node.texture = PlaceholderTexture2D.new();
					node.scale = Vector2.ONE * 32;
					node.position = _points[i] - self.global_position;
					node.name = str("Point", i);
					self.add_child(node);
					node.owner = get_tree().edited_scene_root;
				
				_tip = "Created child Nodes from Points."
			
			# Record child node Global Positions
			# then Delete them.
			else:
			
				var new_points:Array[Vector2];
			
				for child in get_children():
					new_points.push_back(child.global_position);
					_points = new_points;
					child.queue_free();
				
				_tip = "Saved child Node Positions to Points."


func Get_Points() -> Array[Vector2]:
	return _points;
