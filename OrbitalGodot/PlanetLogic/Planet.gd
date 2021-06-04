extends "res://PlanetLogic/Massive.gd"
export var visual_scale: float = 1.0
const SatelliteCenter = preload("res://PlanetLogic/SatelliteCenter.gd")
const gravitator = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#._ready()
	var visual = get_child(0)
	visual.scale *= visual_scale
	var collision = get_child(1)
	collision.scale *= visual_scale
	var satellites: SatelliteCenter = get_child(3)
	satellites.scale *= visual_scale
	satellites.scale_orbit()

func _integrate_forces(state):
	._integrate_forces(state)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
