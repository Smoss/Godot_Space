extends RigidBody
const massive = true
const GravityPair = preload("res://Common/GravityPair.gd")
const cube_root_2 = pow(2.0, 1.0/3)
const partial_denom = (2.0 - cube_root_2)
const c_1_4 = 1 / (2.0 * partial_denom)
const c_2_3 = (1 - cube_root_2) / (2 * partial_denom)
const d_1_3 = 1 / partial_denom
const c_4 = 1 / (2.0)
const d_2 = cube_root_2 / partial_denom
const G_Constant = .1
export var debug: bool = false

var influenced_by : Array = []
var next_lv: Vector3 = Vector3()
var applied_forces: Vector3 = Vector3()

class influencer:
	var mass: float = 0
	var location: Vector3 = Vector3()
	
	func _init(mass, location):
		self.mass = mass
		self.location = location

func gravitationalMagnitude(dist):
	return mass / dist

func apply_gravity(pair: GravityPair):
	var local_translation: Vector3 = pair.second_location
	var target = pair.target
	var target_translation: Vector3 = target.to_global(Vector3())
	var direction: Vector3 = target_translation - local_translation
	var length = direction.length()
	var force_vec = target.mass * direction 
	var lengthSquared = length * length * length
	
	var k1 = mass / lengthSquared * G_Constant
	return force_vec * k1

func calculateStep(state: PhysicsDirectBodyState, location: Vector3):
	var threads: Array = []
	for target in self.influenced_by:
		if target is RigidBody:
			var thread = Thread.new()
			thread.start(self, 'apply_gravity', GravityPair.new(target, location))
			threads.append(thread)
	var force_vec = Vector3()
	for thread in threads:
		force_vec += thread.wait_to_finish()
	
	return (force_vec / self.mass)
	
func _ready():
	next_lv = self.get_linear_velocity()

func _integrate_forces(state: PhysicsDirectBodyState):
	#._integrate_forces(state)
	var delta = state.step
	var half_delta = delta / 2
	var base_lv = Vector3()
	if self.get_colliding_bodies().size() > 0:
		base_lv = state.get_linear_velocity()
	else:
		base_lv = next_lv
	var base_loc = self.to_global(Vector3())
	
	var euler_lv = base_lv + (applied_forces + calculateStep(state, base_loc)) * 1 * delta
	# c1
	base_lv += (applied_forces + calculateStep(state, base_loc)) * d_1_3 * delta
	base_loc += base_lv * c_1_4 * delta 
	
	# c2
	base_lv += (applied_forces + calculateStep(state, base_loc)) * d_2 * delta
	base_loc += base_lv * c_2_3 * delta
	
	# c3
	base_lv += (applied_forces + calculateStep(state, base_loc)) * d_1_3 * delta
	base_loc += base_lv * c_2_3 * delta
	
	# c4
	base_loc += base_lv * c_1_4 * delta
	
	var final_lv = (base_loc - self.to_global(Vector3())) / delta
	state.set_linear_velocity(final_lv)
	final_lv += applied_forces * delta
	state.integrate_forces()
	
	next_lv = base_lv
