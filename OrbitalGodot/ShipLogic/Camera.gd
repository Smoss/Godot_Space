extends KinematicBody
const speed = 33
const Massive = preload("res://Common/Massive.gd")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var target_node: Massive = null# =  get_tree().get_nodes_in_group('camera_follow')[0]
onready var primary_info = $Camera/PrimaryInfo
onready var velocity = $Camera/Velocity

func _ready():
	primary_info.visible = false
	velocity.visible = false

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
	if target_node and target_node is Massive:
		direction += target_node.get_linear_velocity()
		if target_node.primary_body:
			primary_info.text = 'Target Primary:{}\nTarget Altitude:{}\nTarget Roche limit'.format(
				[target_node.primary_body.name, target_node.altitude, target_node.roche_limit],
				'{}'
			)	
		velocity.text = 'Current V {}'.format([target_node.next_lv.length()], '{}')
	self.move_and_slide(direction)
	$Camera/DeltaLabel.text = "Delta: {}".format([delta], '{}')
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed() and event.doubleclick:
		
		var space_state = get_world().direct_space_state
		var mouse_pos = get_viewport().get_mouse_position()
		var origin = $Camera.project_ray_origin(mouse_pos)
		var target = origin + $Camera.project_ray_normal(mouse_pos) * 1000
		
		var intersection = space_state.intersect_ray(origin, target)

		if not intersection.empty() and intersection.collider is Massive:
			var pos = intersection.position
			target_node = intersection.collider
			self.translation = Vector3(0, 100, 0) + target_node.to_global(Vector3())
			self.look_at(target_node.to_global(Vector3()), Vector3(0, 0, -1))
			velocity.visible = true
			if target_node.primary_body:
				primary_info.visible = true
			else:
				primary_info.visible = false
		else:
			target_node = null
			primary_info.visible = false
			velocity.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
