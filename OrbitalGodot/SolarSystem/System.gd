extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var max_ME = 0
var min_ME = INF
var max_V = 0
var min_V = INF
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var planet3Label = get_node("PlayerShip/PlayerCamera/Camera/Velocity")
	var planet3_v = (get_node("PlayerShip").get_linear_velocity() - get_node("Sun").get_linear_velocity())
	#planet3Label.text = 'Current V {}'.format([get_node("PlayerShip").next_lv], '{}')
	#get_node("PlayerShip/PlayerCamera/Camera/DeltaLabel").text = "Delta: {}".format([delta], '{}')
	
#	print(ME)
	#print(delta)
