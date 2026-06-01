extends Node

##PRIVATE VARIABLES

#CAMERA VARS
var _camera : Camera2D
var _shake_strenght := 0.0
var _shake_decay := 5.0

#Functions for Camera shaking, bodozo!


##Func for progresssive camera shake  --- ficou até legal
func _process(delta):
	if _camera and _shake_strenght > 0:
		_shake_strenght = lerp(_shake_strenght, 0.0, _shake_decay * delta)
		_camera.offset = Vector2(
			randf_range(-_shake_strenght, _shake_strenght),
			randf_range(-_shake_strenght, _shake_strenght)
		)
	elif _camera:
		_camera.offset = Vector2.ZERO

## Get my camera
func register_camera(cam: Camera2D):
	_camera = cam
	
func shake(strength: float):
	_shake_strenght = strength
	
## exec shake wihouth decay - UMA BOSTA
#func shake(strength: float):
#	if _camera: 
#		_camera.offset = Vector2(
#			randf_range(-strength, strength),
#			randf_range(-strength, strength)
#		)
