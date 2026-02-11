extends Node

enum SOUND_TYPE { NULL, Metal_Bang, Leaf_Rustle, Leaf_Impact }

const _sounds:Dictionary[String, Array] = {
	
	"Car_Engine_Idle" : [preload("res://Audio/SFX/car/car_engine_idle.wav")],
	"Car_Horn" : [preload("res://Audio/SFX/car/car_horn.wav")],
	"Metal_Bang" : [preload("res://Audio/SFX/car/metal_impact.wav")],
	"Tyre_Screech" : [
		preload("res://Audio/SFX/car/tyre_screech_01.wav"), 
		preload("res://Audio/SFX/car/tyre_screech_02.wav")],
		
	"Leaf_Impact" : [preload("res://Audio/SFX/leaf/leaf_impact.wav")],
	"Leaf_Rustle" : [
		preload("res://Audio/SFX/leaf/leaf_rustle_1.wav"),
		preload("res://Audio/SFX/leaf/leaf_rustle_2.wav"),
		preload("res://Audio/SFX/leaf/leaf_rustle_3.wav")
		],
		
	"Stone_Clack" : [
		preload("res://Audio/SFX/stones/stone_on_concrete_01.wav"),
		preload("res://Audio/SFX/stones/stone_on_concrete_02.wav"),
		preload("res://Audio/SFX/stones/stone_on_concrete_03.wav"),
		preload("res://Audio/SFX/stones/stone_on_concrete_04.wav"),
		preload("res://Audio/SFX/stones/stone_on_concrete_05.wav"),
		preload("res://Audio/SFX/stones/stone_on_concrete_06.wav"),
		preload("res://Audio/SFX/stones/stone_on_concrete_07.wav"),
		preload("res://Audio/SFX/stones/stone_on_concrete_08.wav"),
	]
}

var _audio_player_holder:Node;
var _bgm_player:AudioStreamPlayer;

signal Silenced;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	_audio_player_holder = Node.new();
	_audio_player_holder.name = "SFX_Holder";
	_audio_player_holder.add_child(AudioStreamPlayer2D.new());
	self.add_child(_audio_player_holder);
	
	_Play_BGM();


# Functions: Sounds ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Play_Car_Horn() -> void:
	_Play_Sound(_sounds["Car_Horn"][0], true, .4);


func Play_Car_Engine_Idle() -> void:
	_Play_Sound(_sounds["Car_Engine_Idle"][0], false, .4);


func Play_Metal_Bang() -> void:
	_Play_Sound(_sounds["Metal_Bang"][0], true, 1);


func Play_Tyre_Screech() -> void:
	_Play_Sound(_sounds["Tyre_Screech"][randi_range(0, _sounds["Tyre_Screech"].size() - 1)], true, 1);


func Play_Leaf_Rustle() -> void:
	_Play_Sound(_sounds["Leaf_Rustle"][randi_range(0, _sounds["Leaf_Rustle"].size() - 1)], true, 2);


func Play_Leaf_Impact() -> void:
	_Play_Sound(_sounds["Leaf_Impact"][0], true, 1);


func Play_Stone_Clack() -> void:
	_Play_Sound(_sounds["Stone_Clack"][randi_range(0, _sounds["Stone_Clack"].size() - 1)], true, 1);


func _Play_Sound(audioStream:AudioStream, shiftPitch:bool, vol:float = 1) -> void:
	
	var aud_player:AudioStreamPlayer2D;
	
	# Check all the audio players in the Audio Player Holder
	# to find one that is not currently playing
	# and assign it as the audio player to use.
	for child in _audio_player_holder.get_children():
		if !child.playing:
			aud_player = child;
			break;
	
	# If no audio players are available,
	# create a new one.
	if aud_player == null:
		
		if _audio_player_holder.get_child_count() >= 4:
			return;
		
		aud_player = AudioStreamPlayer2D.new();
		_audio_player_holder.add_child(aud_player);
	
	aud_player.stream = audioStream;
	
	aud_player.volume_linear = vol;
	
	if shiftPitch:
		aud_player.pitch_scale = 1 + randf_range(0, .05);
	
	aud_player.play();


func Fade_All_Sounds_Out() -> void:
	
	var stop_tween:Tween = create_tween();
	
	stop_tween.set_parallel(true);
	
	for aud_player in _audio_player_holder.get_children():
		stop_tween.tween_property(aud_player, "volume_linear", 0, 2);
	
	await stop_tween.finished;
	
	for aud_player in _audio_player_holder.get_children():
		aud_player.stop();
	
	Silenced.emit();


func Play_By_Sound_Type(type:SOUND_TYPE) -> void:
	match type:
		SOUND_TYPE.NULL:
			pass;
		SOUND_TYPE.Metal_Bang:
			Play_Metal_Bang();
		SOUND_TYPE.Leaf_Rustle:
			Play_Leaf_Rustle();
		SOUND_TYPE.Leaf_Impact:
			Play_Leaf_Impact();


# Functions: BGM ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Play_BGM() -> void:
	# Create BGM Player
	_bgm_player = AudioStreamPlayer.new();
	_bgm_player.stream = load("res://Audio/Music/Digimon World - File City (Day).mp3");
	_bgm_player.volume_linear = .15;
	self.add_child(_bgm_player);
	# Play
	_bgm_player.play();
