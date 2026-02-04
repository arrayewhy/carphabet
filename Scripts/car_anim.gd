extends AnimatedSprite2D

const _turn_thresh:float = .6;

const _debug:bool = false;

var _turning:bool;


func _ready() -> void:
	
	if _debug:
		self.add_child(Camera2D.new());
		var label:Label = Label.new();
		label.position += Vector2(-640, -640);
		label.name = "debug_label";
		label.label_settings = LabelSettings.new();
		label.label_settings.font_size = 128;
		self.add_child(label);
	else:
		set_process(false);


func _process(_delta: float) -> void:
	var mouse_pos:Vector2 = get_global_mouse_position();
	var direction:Vector2 = (mouse_pos - self.global_position).normalized();
	Animate(direction);


func Animate(direction:Vector2) -> void:
	
	#const thresh_mod:float = 2;
	
	# Vertical
	#if abs(direction.y) > abs(direction.x):
		
	# Up
	if direction.y < 0:
		
		# Left
		if direction.x < 0:
			
			if direction.x > -0.1:
				play('North');
			elif direction.x < -0.9:
				play('West');
				
			elif direction.x < -0.4 && direction.x > -0.6:
				play('North_West');
			
			elif direction.x > -0.5:
				play('North_West_Upper');
			elif direction.x < -0.5:
				play('North_West_Lower');
		
		# Right
		elif direction.x > 0:
			
			if direction.x < 0.1:
				play('North');
			elif direction.x > 0.9:
				play('East');
			
			elif direction.x > 0.4 && direction.x < 0.6:
				play('North_East');
			
			elif direction.x < 0.5:
				play('North_East_Upper');
			elif direction.x > 0.5:
				play('North_East_Lower');
		
	# Down
	elif direction.y > 0:
		
		# Left
		if direction.x < 0:
			
			if direction.x > -0.1:
				play('South');
			elif direction.x < -0.9:
				play('West');
			
			elif direction.x < -0.4 && direction.x > -0.6:
				play('South_West');
			
			elif direction.x > -0.5:
				play('South_West_Lower');
			elif direction.x < -0.5:
				play('South_West_Upper');
		
		# Right
		elif direction.x > 0:
			
			if direction.x < 0.1:
				play('South');
			elif direction.x > 0.9:
				play('East');
			
			elif direction.x > 0.4 && direction.x < 0.6:
				play('South_East');
			
			elif direction.x < 0.5:
				play('South_East_Lower');
			elif direction.x > 0.5:
				play('South_East_Upper');
				
	else:
		
		if direction.x < 0:
			play('West');
			
		elif direction.x > 0:
			play('East');
			
	#print(str(self.animation, " : ", direction));
	
	return;
	
	if _turning:
		return;
	
	_turning = true;
	
	if abs(direction.x) < 0.3:
		if direction.y < 0: # North
			play("North");
			if _debug: $"debug_label".text = "North" + str(direction);
		elif direction.y > 0: # South
			play("South");
			if _debug: $"debug_label".text = "South" + str(direction);
		#return;
	
	elif abs(direction.y) < 0.3:
		if direction.x < 0: # West
			play("West");
			if _debug: $"debug_label".text = "West" + str(direction);
		elif direction.x > 0: # East
			play("East");
			if _debug: $"debug_label".text = "East" + str(direction);
		#return;
	
	if direction.x > 0: # Right
		
		if direction.y < 0: # North East
			
			if abs(direction.x) > _turn_thresh && abs(direction.y) > _turn_thresh:
				play("North_East");
				if _debug: $"debug_label".text = "North_East" + str(direction);
				#return;
			elif abs(direction.x) < abs(direction.y):
				play("North_East_Upper");
				if _debug: $"debug_label".text = "North_East_Upper" + str(direction);
				#return;
			elif abs(direction.x) > abs(direction.y):
				play("North_East_Lower");
				if _debug: $"debug_label".text = "North_East_Lower" + str(direction);
				#return;
				
		elif direction.y > 0: # South East
			
			if abs(direction.x) > _turn_thresh && abs(direction.y) > _turn_thresh:
				play("South_East");
				if _debug: $"debug_label".text = "South_East" + str(direction);
				#return;
			elif abs(direction.x) > abs(direction.y):
				play("South_East_Upper");
				if _debug: $"debug_label".text = "South_East_Upper" + str(direction);
				#return;
			elif abs(direction.x) < abs(direction.y):
				play("South_East_Lower");
				if _debug: $"debug_label".text = "South_East_Lower" + str(direction);
				#return;
	
	elif direction.x < 0: # Left
		
		if direction.y < 0: # North West
			
			if abs(direction.x) > _turn_thresh && abs(direction.y) > _turn_thresh:
				play("North_West");
				if _debug: $"debug_label".text = "North_West" + str(direction);
				#return;
			elif abs(direction.x) < abs(direction.y):
				play("North_West_Upper");
				if _debug: $"debug_label".text = "North_West_Upper" + str(direction);
				#return;
			elif abs(direction.x) > abs(direction.y):
				play("North_West_Lower");
				if _debug: $"debug_label".text = "North_West_Lower" + str(direction);
				#return;
			
		elif direction.y > 0: # South West
			
			if abs(direction.x) > _turn_thresh && abs(direction.y) > _turn_thresh:
				play("South_West");
				if _debug: $"debug_label".text = "South_West" + str(direction);
				#return;
			elif abs(direction.x) > abs(direction.y):
				play("South_West_Upper");
				if _debug: $"debug_label".text = "South_West_Upper" + str(direction);
				#return;
			elif abs(direction.x) < abs(direction.y):
				play("South_West_Lower");
				if _debug: $"debug_label".text = "South_West_Lower" + str(direction);
				#return;
				
	await get_tree().create_timer(.2).timeout;
	
	_turning = false;
