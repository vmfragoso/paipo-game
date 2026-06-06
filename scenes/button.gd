extends RigidBody2D

#Global Variables
var Maguila = preload("res://scenes/maguila.tscn")

func on_pressed(quem):
	print("Entrou no botao")
	$AnimatedSprite2D.play("pressed")
	var maguila = Maguila.instantiate()
	get_tree().current_scene.add_child(maguila)
	maguila.start(Vector2(400, 600), quem)
	print(global_position.x)
