extends Node

#CONST
const SWEETIE_16 := {
	"black":      Color("1a1c2c"),
	"purple":     Color("5d275d"),
	"red":        Color("b13e53"),
	"orange":     Color("ef7d57"),
	"yellow":     Color("ffcd75"),
	"lime":       Color("a7f070"),
	"green":      Color("38b764"),
	"teal":       Color("257179"),
	"navy":       Color("29366f"),
	"blue":       Color("3b5dc9"),
	"sky":        Color("41a6f6"),
	"cyan":       Color("73eff7"),
	"white":      Color("f4f4f4"),
	"light_gray": Color("94b0c2"),
	"gray":       Color("566c86"),
	"dark_gray":  Color("333c57"),
}

#$Sprite2D.modulate = Util.SWEETIE_16.red
#var c = Util.SWEETIE_16_LIST[4]   # amarelo
#var d = Util.sweetie(20)          # faz wrap → índice 4

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
