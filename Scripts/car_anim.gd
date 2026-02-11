extends AnimatedSprite2D

var _turning:bool;


func _ready() -> void:
	set_process(false);


func Animate(direction:Vector2) -> void:
	
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
		
		else:
			play('North');
		
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
			play('South');
				
	else:
		
		if direction.x < 0:
			play('West');
			
		elif direction.x > 0:
			play('East');
			
	#print(str(self.animation, " : ", direction));
