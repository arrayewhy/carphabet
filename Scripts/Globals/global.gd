extends Node

const Scenes:Dictionary[String, String] = {
	"A" : "res://Scenes/A.tscn",
	"B" : "res://Scenes/B.tscn",
	"C" : "res://Scenes/C.tscn",
}


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Cancel"):
		match get_tree().current_scene.name:
			"A": get_tree().change_scene_to_file(Scenes["A"]);
			"B": get_tree().change_scene_to_file(Scenes["B"]);
			"C": get_tree().change_scene_to_file(Scenes["C"]);
