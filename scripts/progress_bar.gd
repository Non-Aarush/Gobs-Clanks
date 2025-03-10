extends ProgressBar


var parent
var max_val
var min_val

func _ready():
	parent = getparent()
	max_val = parent.health_max
	min_val = parent.health_min
	
	func _process(delta):
		self.value = parent.health
		if parent.health != max_val:
			self.visible= true
			if player.health == min_val:
				self.visibile = false 
		else:
			self.visible = false
