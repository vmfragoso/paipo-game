extends Node2D

func _ready():
	print("MAIN: Ball existe? ", has_node("Ball"))
	print("MAIN: HUD existe? ", has_node("HUD"))
	$Ball.hp_changed.connect($HUD.set_hp)	
	print("MAIN: conectado? ", $Ball.hp_changed.is_connected($HUD.set_hp))
