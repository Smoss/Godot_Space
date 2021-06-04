extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#var total_energy = 0
	var ke = 0
	var pe = 0
	for child in get_children():
		if child is RigidBody:
			for child_2 in get_children():
				if child_2 is RigidBody and child != child_2:
					
					ke += (child.get_linear_velocity() - child_2.get_linear_velocity()).length_squared() / 2 * child.mass
					pe += (child.to_global(Vector3()) - child_2.to_global(Vector3())).length() * child.mass
	print(ke + pe)
	#print(delta)
