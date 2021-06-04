extends RigidBody
const massive = true
const GravityPair = preload("res://PlanetLogic/GravityPair.gd")
const cube_root_2 = pow(2.0, 1.0/3)
const partial_denom = (2.0 - cube_root_2)
const c_1_4 = 1 / (2.0 * partial_denom)
const c_2_3 = (1 - cube_root_2) / (2 * partial_denom)
const d_1_3 = 1 / partial_denom
const c_4 = 1 / (2.0)
const d_2 = cube_root_2 / partial_denom
export var debug: bool = false

var influenced_by : Array = []
var prev_lv: Vector3 = Vector3()

class influencer:
	var mass: float = 0
	var location: Vector3 = Vector3()
	
	func _init(mass, location):
		self.mass = mass
		self.location = location

func gravitationalMagnitude(dist):
	return mass / dist

#func forceVector(target: RigidBody):
	#var parent = get_parent() as RigidBody
	#var local_translation: Vector3 = parent.to_global(Vector3())
	#var target_translation: Vector3 = target.to_global(Vector3())
	#var direction: Vector3 = localTranslation - targetTranslation
	#var length = direction.length()
	#var force_vec = target.mass * direction / length
	#return force_vec

func apply_gravity(pair: GravityPair):
	var local_translation: Vector3 = pair.second_location
	var target = pair.target
	var target_translation: Vector3 = target.to_global(Vector3())
	var direction: Vector3 = target_translation - local_translation
	var length = direction.length()
	var force_vec = target.mass * direction 
	var lengthSquared = length * length * length
	
	var k1 = mass / lengthSquared
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	print(self.to_global(Vector3()))
#	var threads: Array = []
#	for target in influenced_by:
#		if target is RigidBody:
#			var thread = Thread.new()
#			thread.start(self, 'apply_gravity', target)
#			threads.append(thread)
#	var force_vec = Vector3()
#	for thread in threads:
#		force_vec += thread.wait_to_finish()
	#self.add_central_force(force_vec)
	
func _ready():
	prev_lv = self.get_linear_velocity()

func _physics_process(delta):
	pass

func _integrate_forces(state: PhysicsDirectBodyState):
	var delta = state.step
	var half_delta = delta / 2
	var base_lv = state.get_linear_velocity()
	#state.set_linear_velocity(Vector3())
	var base_loc = self.to_global(Vector3())
	
	var euler_lv = base_lv + calculateStep(state, base_loc) * 1 * delta
	# c1
	base_lv += calculateStep(state, base_loc) * d_1_3 * delta
	base_loc += base_lv * c_1_4 * delta 
	
	# c2
	base_lv += calculateStep(state, base_loc) * d_2 * delta
	base_loc += base_lv * c_2_3 * delta
	
	# c3
	base_lv += calculateStep(state, base_loc) * d_1_3 * delta
	base_loc += base_lv * c_2_3 * delta
	
	# c4
	base_loc += base_lv * c_1_4 * delta
	
	var final_lv = (base_loc - self.to_global(Vector3())) / delta
	state.set_linear_velocity(prev_lv)
	#print(final_lv)
	prev_lv = final_lv
	#print(delta)
	
	#base_lv += k1
	#var k2 = calculateStep(state, self.to_global((base_lv + k1) * half_delta))
	#var k3 = calculateStep(state, self.to_global((base_lv + k2) * half_delta))
	#var k4 = calculateStep(state, self.to_global((base_lv + k3) * delta))

	#var ode = calculateStep(state, self.to_global((base_lv) * delta))
	#var lv = ((k1 + 2 * k2 + 2 * k3 + k4)) / 6 + base_lv
	#var poss_lv = ode + base_lv
	#print(poss_lv - euler_lv)
	#state.set_transform(state.transform.translated(lv * delta))
	#state.set_linear_velocity(lv)
	#tru_linear_velocity = lv
	#loc = loc.translated(tru_linear_velocity * delta)
	#print(loc.origin - state.transform.origin)
	#state.set_transform(loc)
	#self.apply_central_impulse(lv * mass)
	#._integrate_forces(state)
