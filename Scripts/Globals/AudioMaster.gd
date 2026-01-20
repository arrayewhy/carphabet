extends Node

const _sounds:Dictionary[String, AudioStream] = {
	"Car_Horn" : preload("res://Audio/SFX/car_horn.wav"),
}

var _audio_player_holder:Node;


func _ready() -> void:
	
	_audio_player_holder = Node.new();
	_audio_player_holder.name = "SFX_Holder";
	_audio_player_holder.add_child(AudioStreamPlayer2D.new());
	self.add_child(_audio_player_holder);


func Play_CarHorn(shiftPitch:bool = false) -> void:
	_Play_Sound(_sounds["Car_Horn"], shiftPitch);


func _Play_Sound(audioStream:AudioStream, shiftPitch:bool) -> void:
	
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
	
	if shiftPitch:
		aud_player.pitch_scale = 1 + randf_range(0, .05);
	
	aud_player.play();
