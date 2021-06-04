extends Spatial
var orbitalPace: float = 0
var orbitalPeriod: float = 10

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func scale_orbit():
	self.orbitalPeriod *= self.scale.length_squared()
	self.orbitalPeriod = min(self.orbitalPeriod, 5)
	self.orbitalPace = 2 * PI / self.orbitalPeriod
	for child in self.get_children():
		if child is Spatial:
			child.scale /= self.scale

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.transform = self.transform.rotated(Vector3(0, 1, 0), orbitalPace * delta)
#	pass
