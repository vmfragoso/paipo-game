extends RigidBody2D

@onready var particles = $hitParticles




func hit_effect():
	print("BOLA APANHOU E FICOU BRANCA")
	particles.emitting = true
	$Sprite2D.modulate = Color(10, 10, 10, 1)  # white Super Brilliant pa caraleop colo.withe nao funciona
	await get_tree().create_timer(0.5).timeout
	$Sprite2D.modulate = Color(1, 1, 1, 1)  # back to normal
	
	#matrix effect
	#Engine.time_scale = 0.05
	#await get_tree().create_timer(0.05).timeout
	#Engine.time_scale = 1.0
