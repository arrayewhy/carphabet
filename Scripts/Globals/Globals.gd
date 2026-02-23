extends Node

enum SceneType { Null, A, B, C, D }
var CURRENT_SCENE_TYPE:SceneType;

const Scenes:Dictionary[SceneType, String] = {
	SceneType.A : "res://Scenes/cap_a.tscn",
	SceneType.B : "res://Scenes/cap_b.tscn",
	SceneType.C : "res://Scenes/cap_c.tscn",
	SceneType.D : "res://Scenes/cap_d.tscn",
}


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Cancel"):
		_Reload_Current_Scene();
		return;
	if Input.is_action_just_pressed("ui_right"):
		Progress_To_Next_Scene();
		return;


# Functions: Scene ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Progress_To_Next_Scene() -> void:
	match CURRENT_SCENE_TYPE:
		SceneType.A:
			get_tree().change_scene_to_file(Scenes[SceneType.B]);
		SceneType.B:
			get_tree().change_scene_to_file(Scenes[SceneType.C]);
		SceneType.C:
			get_tree().change_scene_to_file(Scenes[SceneType.A]);


func _Reload_Current_Scene() -> void:
	get_tree().change_scene_to_file(Scenes[CURRENT_SCENE_TYPE]);
