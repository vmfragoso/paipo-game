extends RigidBody2D

@onready var particles = $hitParticles
@onready var label_damage = $Label


#CONST
const HP_MAX = 10


#GLOBAL VARIABLES

var impact_position : Vector2
var tween_atual: Tween
var wobble_atual: Tween
var hp: int = HP_MAX 
signal hp_changed(current_hp,max_hp)

func _ready() -> void:
	label_damage.modulate.a = 0.0  # Start invesiblah!
	label_damage.top_level = true

func hit_effect(matrix_ativo: bool, hit_impact):
	print("BOLA APANHOU E FICOU BRANCA")
	take_damage(hit_impact)
	impact_position = self.global_position + Vector2(0,-16)
	
	wiggle_wiggle_wiggle(hit_impact)
	
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
		
		
func take_damage (hit_impact):
	if hp <= 0:
		hp = 10
	var damage = 1
	if hit_impact >= 900:
		damage = 2
	hp = max(0, hp - damage)
	
	print("BALL: vou emitir. Conexões = ", hp_changed.get_connections().size())
	print("BALL: lista = ", hp_changed.get_connections())
	hp_changed.emit(hp, HP_MAX)
	print("BALL: emiti.")
	
	print("Bola tomou %d de dano. HP atual: %d/%d" % [damage, hp, HP_MAX])

	
func wiggle_wiggle_wiggle (hit_impact):
	if tween_atual and tween_atual.is_valid():
		tween_atual.kill()

	
	
	label_damage.text = str(round(hit_impact))
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
