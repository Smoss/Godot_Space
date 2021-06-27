extends "res://Common/Massive.gd"
const FORCE_MAGNITUDE = 33
const THROTTLE_SHIFT = 1.0 / 2.0
var throttle = 0

signal forcing
# Called when the node enters the scene tree for the first time.

func _process(delta):
	var curr_throttle_shift = 0
	if Input.is_action_pressed("increase_throttle"):
		curr_throttle_shift += THROTTLE_SHIFT * delta
	elif Input.is_action_pressed("decrease_throttle"):
		curr_throttle_shift -= THROTTLE_SHIFT * delta
	throttle += curr_throttle_shift
	throttle = clamp(throttle, 0, 1)
	

func _ready():
	var velocity_label = get_tree().get_nodes_in_group('velocity_label')[0]
	self.connect('forcing', velocity_label, '_forcing')

func _physics_process(delta):
	var magnitude = FORCE_MAGNITUDE * throttle
	self.applied_forces = self.transform.basis.z * magnitude * self.mass
	emit_signal('forcing', self.applied_forces)
	var rot = Vector3()
	if Input.is_action_pressed("ui_right"):
		rot.y -= 1
	if Input.is_action_pressed("ui_left"):
		rot.y += 1
	
	if Input.is_action_pressed("damp_rot"):
		rot = self.get_angular_velocity() * -1
	self.add_torque(rot)
	
func _integrate_forces(state):
	._integrate_forces(state)
	if state.get_angular_velocity().length_squared() > 1:
		state.set_angular_velocity(state.get_angular_velocity().normalized())
