# In the HealthBar script
extends ProgressBar

var parent
var max_val
var min_val

func _ready():
	parent = get_parent()
	max_val = parent.health_max
	min_val = parent.health_min

func _process(delta):
	self.max_value = max_val
	self.min_value = min_val
	self.value = parent.health
	if parent.health != max_val:
		self.visible = true
	else:
		self.visible = false
