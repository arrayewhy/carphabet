extends Node

enum SceneType { Null, A, B, C }
var CURRENT_SCENE_TYPE:SceneType;

const Scenes:Dictionary[SceneType, String] = {
	SceneType.A : "res://Scenes/A.tscn",
	SceneType.B : "res://Scenes/B.tscn",
	SceneType.C : "res://Scenes/C.tscn",
}


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Cancel"):
		_Reload_Current_Scene();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Progress_To_Next_Scene() -> void:
	match CURRENT_SCENE_TYPE:
		SceneType.A:
			get_tree().change_scene_to_file(Scenes[SceneType.B]);
		SceneType.B:
			get_tree().change_scene_to_file(Scenes[SceneType.C]);
		SceneType.C:
			get_tree().change_scene_to_file(Scenes[SceneType.A]);


func _Reload_Current_Scene() -> void:
	match CURRENT_SCENE_TYPE:
		SceneType.A:
			get_tree().change_scene_to_file(Scenes[SceneType.A]);
		SceneType.B:
			get_tree().change_scene_to_file(Scenes[SceneType.B]);
		SceneType.C:
			get_tree().change_scene_to_file(Scenes[SceneType.C]);
