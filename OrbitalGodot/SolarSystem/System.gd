extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var planet3_v = (get_node("PlayerShip").get_linear_velocity() - get_node("Sun").get_linear_velocity())
	
#	print(ME)
	#print(delta)
