extends Area
var influenced: Array = []
var mass: float = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const GravityPair = preload("res://PlanetLogic/GravityPair.gd")

func apply_gravity(gravityPair: GravityPair):
	var target = gravityPair.target
	var delta = gravityPair.delta
	var parent = get_parent() as RigidBody
	var localTranslation: Vector3 = parent.to_global(Vector3())
	var targetTranslation: Vector3 = target.to_global(Vector3())
	var direction: Vector3 = localTranslation - targetTranslation
	var length = direction.length()
	var force = (mass * target.mass) * direction / length 
	var lengthSquared = length * length
	target.add_central_force(force / lengthSquared)
	#print(localTranslation, parent.transform)
	#print(target.linear_velocity, force / lengthSquared, force)

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent() as Spatial
	if parent is RigidBody:
		scale *= (parent.mass * 10)
		mass = parent.mass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	var threads: Array = []
	for target in influenced:
		if target is RigidBody:
			var thread = Thread.new()
			thread.start(self, 'apply_gravity', GravityPair.new(target, delta))
			threads.append(thread)
	for thread in threads:
		thread.wait_to_finish()


func _on_GravityArea_body_entered(body):
	if body is RigidBody and body != get_parent() and not influenced.has(body):
			influenced.append(body)
