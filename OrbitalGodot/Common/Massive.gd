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

onready var future_path = $FuturePath
var influenced_by : Array = []
var next_lv: Vector3 = Vector3()
var applied_forces: Vector3 = Vector3()
var altitude = 0
var primary_body: RigidBody = null
var roche_limit: float = 0.0
var forces: Dictionary = {}

var m = SpatialMaterial.new()

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
	if target != primary_body and target.mass > self.mass and length + 5 < altitude:
		primary_body = target
		altitude = length
	elif target == primary_body:
		altitude = length
	var force_vec = target.mass * direction 
	var lengthSquared = length * length * length
	
	var k1 = mass / lengthSquared * G_Constant
	if target.mass > self.mass:
		forces[target] = [force_vec, length]
	return force_vec * k1

func calculateStep(location: Vector3):
	var threads: Array = []
	forces = {}
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
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color.white

func calc_full_step(delta: float, linear_vel: Vector3, base_loc: Vector3):
	var init_loc = base_loc + Vector3()
	var base_lv = Vector3()
	if self.get_colliding_bodies().size() > 0:
		base_lv = linear_vel
	else:
		base_lv = self.next_lv
	#var base_loc = self.to_global(Vector3())
	
	var euler_lv = base_lv + (applied_forces + calculateStep(base_loc)) * 1 * delta
	# c1
	base_lv += (applied_forces + calculateStep(base_loc)) * d_1_3 * delta
	base_loc += base_lv * c_1_4 * delta 
	
	# c2
	base_lv += (applied_forces + calculateStep(base_loc)) * d_2 * delta
	base_loc += base_lv * c_2_3 * delta
	
	# c3
	base_lv += (applied_forces + calculateStep(base_loc)) * d_1_3 * delta
	base_loc += base_lv * c_2_3 * delta
	
	# c4
	base_loc += base_lv * c_1_4 * delta
	
	return [(base_loc - init_loc) / delta, base_lv]
	
func _physics_process(delta):
	var curr_loc = self.to_global(Vector3())
	var test_lv = calc_full_step(1, self.get_linear_velocity(), curr_loc)[0]
	var next_loc = curr_loc + test_lv
	if future_path is ImmediateGeometry:
		future_path.clear()
		future_path.set_material_override(m)
		future_path.begin(Mesh.PRIMITIVE_POINTS, null)
		future_path.add_vertex(Vector3())
		future_path.add_vertex(test_lv)
		future_path.end()
		future_path.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
		future_path.add_vertex(Vector3())
		future_path.add_vertex(test_lv)
		future_path.end()

func _integrate_forces(state: PhysicsDirectBodyState):
	var delta = state.step
	var lv_pair = calc_full_step(delta, state.get_linear_velocity(), self.to_global(Vector3()))
	var final_lv = lv_pair[0]
	var base_lv = lv_pair[1]
	state.set_linear_velocity(final_lv)
	state.integrate_forces()
	
	next_lv = base_lv
	
	for gravitor in forces:
		if gravitor == primary_body:
			altitude = forces[gravitor][1]
		elif not forces.has(primary_body) or not primary_body or forces[gravitor][0] > forces[primary_body][0]:
			primary_body = gravitor
			altitude = forces[gravitor][1]
