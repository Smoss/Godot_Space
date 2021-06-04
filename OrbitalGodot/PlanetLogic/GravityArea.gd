extends Area
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const Massive = preload("res://PlanetLogic/Massive.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent() as Spatial
	if parent is RigidBody:
		scale *= (parent.mass * 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float):


func _on_GravityArea_body_entered(body: Node):
	if body.gravitator and body != get_parent():
		var parent: RigidBody = get_parent()
		var target: Massive = body
		if not target.influenced_by.has(parent):
			target.influenced_by.append(parent)


func _on_GravityArea_body_exited(body: Node):
	if body.gravitator:
		var parent = get_parent()
		var idx = body.influenced_by.find(parent)
		if idx >= 0:
			body.influenced_by.remove(idx)
