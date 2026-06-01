extends RigidBody2D

@onready var particles = $hitParticles




func hit_effect():
	print("BOLA APANHOU E FICOU BRANCA")
	particles.emitting = true
	$Sprite2D.modulate = Color(50, 50, 50, 1)  # white Super Brilliant pa caraleop colo.withe nao funciona acho que se eu aumentar melhora
	await get_tree().create_timer(0.2).timeout
	$Sprite2D.modulate = Color(1, 1, 1, 1)  # back to normal
	
	#matrix effect
	#Engine.time_scale = 0.05
	#await get_tree().create_timer(0.05).timeout
	#Engine.time_scale = 1.0
