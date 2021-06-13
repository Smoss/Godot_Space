extends KinematicBody
const speed = 33


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var scale: Vector3 = Vector3()
	var self_basis: Basis = self.transform.basis
	if Input.is_action_pressed("zoom_out"):
		scale.y += speed
	if Input.is_action_pressed("zoom_in"):
		scale.y -= speed
		
	
	if Input.is_action_pressed("move_camera_left"):
		scale.x -= speed
	if Input.is_action_pressed("move_camera_right"):
		scale.x += speed
	if Input.is_action_pressed("move_camera_up"):
		scale.z -= speed
	if Input.is_action_pressed("move_camera_down"):
		scale.z += speed
	
	var direction = self.get_parent().transform.basis.xform(scale)
	self.get_node("Camera/Camera Motion").text = 'Camera Vector: {} with global {} on basis {}'.format([direction, self.translation, self.transform.basis], '{}')
	self.move_and_slide(direction)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
