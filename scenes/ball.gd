extends RigidBody2D

@onready var particles = $hitParticles
@onready var label_damage = $Label

#GLOBAL VARIABLES

var impact_position : Vector2
var tween_atual: Tween
var wobble_atual: Tween

func _ready() -> void:
	label_damage.modulate.a = 0.0  # Start invesiblah!
	label_damage.top_level = true

func hit_effect(matrix_ativo: bool, damage):
	print("BOLA APANHOU E FICOU BRANCA")
	
	impact_position = self.global_position + Vector2(0,-16)
	
	wiggle_wiggle_wiggle(damage)
	
	particles.emitting = true
	# white Super Brilliant pa caraleop colo.withe nao funciona acho que se eu aumentar melhora
	$Sprite2D.modulate = Color(50, 50, 50, 1)  
	await get_tree().create_timer(0.2).timeout
	$Sprite2D.modulate = Color(1, 1, 1, 1)  # back to normal
	
	
	
	
	#matrix effect
	if matrix_ativo:
		print("Matrix State:", matrix_ativo)
		
		Engine.time_scale = 0.05
		await get_tree().create_timer(0.05).timeout
		Engine.time_scale = 1.0
		
	
func wiggle_wiggle_wiggle (damage):
	if tween_atual and tween_atual.is_valid():
		tween_atual.kill()
	if wobble_atual and wobble_atual.is_valid():
		wobble_atual.kill()
	
	
	label_damage.text = str(round(damage))
	# Reseta posição e opacidade
	label_damage.global_position = impact_position
	label_damage.modulate.a = 1.0
	label_damage.rotation = 0
	
		
	# Cria o tween (animação)
	var tween = create_tween()
	tween.set_parallel(true)  # várias animações ao mesmo tempo
	
	# FADE IN/OUT
	tween.tween_property(label_damage, "modulate:a", 1.0, 0.1)
	tween.tween_property(label_damage, "modulate:a", 0.0, 0.8).set_delay(0.4)
	
	# 
	tween.tween_property(
		label_damage, 
		"global_position:y", 
		impact_position.y - 50, 
		1.2
	)
	
	# faz o wigle wiglw wigle!
	var wobble_tween = create_tween()
	wobble_tween.set_loops(6)  # 4 ciclos de balanço
	wobble_tween.tween_property(label_damage, "rotation", deg_to_rad(20), 0.07)
	wobble_tween.tween_property(label_damage, "rotation", deg_to_rad(-20), 0.14)
	wobble_tween.tween_property(label_damage, "rotation", deg_to_rad(0), 0.07)
