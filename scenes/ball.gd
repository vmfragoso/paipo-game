extends RigidBody2D

@export var piece_scene: PackedScene
@export var pieces_spritesheet: Texture2D
@export var piece_size: int = 16

@onready var particles = $hitParticles
@onready var label_damage = $Label
@onready var explosion_particles = $Explosion


#CONST
const HP_MAX = 10



#GLOBAL VARIABLES

var impact_position : Vector2
var tween_atual: Tween
var wobble_atual: Tween
var hp: int = HP_MAX 
var is_dying = false
var ball_pieces =[]

#SIGNALS
signal hp_changed(current_hp,max_hp)

func _ready() -> void:
	label_damage.modulate.a = 0.0  # Start invesiblah!
	label_damage.top_level = true

func hit_effect(matrix_ativo: bool, hit_impact):
	print("BOLA APANHOU E FICOU BRANCA")
	if is_dying:
		return
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
	var damage = 1
	if hit_impact >= 900:
		damage = 2
	hp = max(0, hp - damage)
	
	#print("BALL: vou emitir. Conexões = ", hp_changed.get_connections().size())
	#print("BALL: lista = ", hp_changed.get_connections())
	hp_changed.emit(hp, HP_MAX)
	print("Bola tomou %d de dano. HP atual: %d/%d" % [damage, hp, HP_MAX])
	
	if hp <= 0:
		die()

	
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

func die():
	print("=== DIE CHAMADO ===")
	$CollisionShape2D.set_deferred("disabled", true)
	is_dying = true
	#print("Velocidade atual: ", linear_velocity.length())
	#while linear_velocity.length() > 5:
	#	await get_tree().process_frame
	#		print("Bola parou. Velocidade: ", linear_velocity.length())
	
	#await get_tree().process_frame
	

	set_deferred("freeze" ,true)
	print("Freeze setado")
	
	await implosion_shake(0.8)
	print("Shake terminou")
	
	$Sprite2D.visible = false
	$CollisionShape2D.set_deferred("disable", true)
	print("Bola escondida, vou spawnar pedaços")
	
	spawn_pieces()
	explosion_particles.emitting = true
	
	
	await get_tree().create_timer(5.0).timeout
	print("5 segundos passaram")
	
	await gather_pieces(0.4)
	print("Gather terminou")
	
	respawn()
	print("Respawn feito")
	
	
func implosion_shake(duration):
	var original_pos = position
	var elapsed = 0.0
	while elapsed < duration:
		# shaking shaking
		var intensity = lerp(0.5, 2.5, elapsed / duration)
		position = original_pos + Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		elapsed += get_process_delta_time()
		await get_tree().process_frame
	position = original_pos
	
func spawn_pieces():
	
	print("=== SPAWN PIECES ===")
	print("piece_scene: ", piece_scene)
	print("pieces_spritesheet: ", pieces_spritesheet)
	print("piece_size: ", piece_size)
	
	var no_friction_mat = PhysicsMaterial.new()
	no_friction_mat.friction = 0.0
	no_friction_mat.bounce = 0.5
	
	ball_pieces.clear()
	for i in range(4):
		var piece = piece_scene.instantiate()
		piece.continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
		get_parent().add_child(piece)
		piece.global_position = global_position
		piece.gravity_scale = 1.0
		piece.physics_material_override = no_friction_mat
		
		# recorta a região do pedaço i do spritesheet
		var atlas = AtlasTexture.new()
		atlas.atlas = pieces_spritesheet
		atlas.region = Rect2(i * piece_size, 0, piece_size, piece_size)
		piece.get_node("Sprite2D").texture = atlas
		
		# impulso pra fora em 4 diagonais
		var horizontal_force = randf_range(-100, 200)
		var vertical_force = randf_range(-600, -750)  # negativo = pra cima
		var force = Vector2(horizontal_force, vertical_force)
		
		piece.apply_impulse(force)
		
		piece.angular_velocity = randf_range(-10, 10)

		
		ball_pieces.append(piece)
		
		
func gather_pieces(duration):
	var start_positions = []
	for p in ball_pieces:
		p.freeze = true
		start_positions.append(p.global_position)
	
	var elapsed = 0.0
	while elapsed < duration:
		var t = elapsed / duration
		for i in range(ball_pieces.size()):
			ball_pieces[i].global_position = start_positions[i].lerp(global_position, t)
		elapsed += get_process_delta_time()
		await get_tree().process_frame
	
	for p in ball_pieces:
		p.queue_free()
	ball_pieces.clear()
	
func respawn():
	$Sprite2D.visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	set_deferred("freeze", false)
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	hp = HP_MAX
	is_dying = false
	hp_changed.emit(hp, HP_MAX)
