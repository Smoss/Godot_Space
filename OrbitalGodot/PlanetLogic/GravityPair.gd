extends Node


var target: RigidBody
var delta: float
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init(targ, delt):
	self.target = targ
	self.delta = delt

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
