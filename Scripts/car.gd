extends Node2D

@onready var _arrow_path:Path2D = $"../Arrow/Path2D";
@onready var _arrow_path_follow:PathFollow2D = $"../Arrow/Path2D/PathFollow2D";

const _speed:float = 200;
var _drive:bool;

var _last_pos:Vector2;


func _ready() -> void:
	_arrow_path.Arrow_Complete.connect(_Drive);
	_arrow_path_follow.loop = false;
	_arrow_path_follow.rotates = false;
	
	$Area2D.area_entered.connect(_Contact);
	
	$"..".Win.connect(_Move_To_EndPoint);


func _process(delta: float) -> void:
	
	if _drive:
		
		_arrow_path_follow.progress += delta * _speed;
		self.global_position = _arrow_path_follow.global_position;
		var direction:Vector2 = self.global_position - _last_pos;
		direction = direction.normalized();
		_last_pos = self.global_position;
		
		# Animation
		$AnimatedSprite2D.Animate(direction);


func _Drive() -> void:
	_last_pos = self.global_position;
	_drive = true;


func _Contact(area:Area2D) -> void:
	match area.name:
		"Crash_Zone":
			print("Bang!");
			_drive = false;


func _Move_To_EndPoint(endPoint:Vector2) -> void:

	_drive = false;
	
	$AnimatedSprite2D.Animate((endPoint - global_position).normalized());
	
	var tween:Tween = create_tween();
	tween.set_trans(Tween.TRANS_QUAD);
	tween.set_ease(Tween.EASE_OUT);
	tween.tween_property(self, "global_position", endPoint, 2);
	
	await tween.finished;
	await get_tree().create_timer(2).timeout;
	
	match get_tree().current_scene.name:
		"A": get_tree().change_scene_to_file("res://Scenes/B.tscn");
		"B": get_tree().change_scene_to_file("res://Scenes/C.tscn");
		"C": get_tree().change_scene_to_file("res://Scenes/A.tscn");
