extends CanvasLayer

var _tween:Tween;

signal Curtain_Sequence_Complete;


func _ready() -> void:
	_tween = create_tween();


func Reveal() -> void:
	
	if _tween.is_running():
		_tween.kill();
	
	_tween = create_tween();
	_tween.tween_property($ColorRect, "modulate:a", 0, 1);
	
	$ColorRect.show();
	
	await _tween.finished;
	
	$ColorRect.hide();
	
	Curtain_Sequence_Complete.emit();


func Obscure() -> void:
	
	if _tween.is_running():
		_tween.kill();
	
	_tween = create_tween();
	_tween.tween_property($ColorRect, "modulate:a", 1, 1);
	
	$ColorRect.show();
	
	await _tween.finished;
	
	Curtain_Sequence_Complete.emit();
