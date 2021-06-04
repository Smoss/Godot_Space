extends Node


var target: RigidBody
var second_location: Vector3
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init(targ, location):
	self.target = targ
	self.second_location = location

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
