extends CharacterBody2D

#CONS
const SPEED = 130.0
const p2_jump_FORCE = -400
const GRAVITY = 800

##PRIVATE VARIABLES
var matrix_ativo := false
var p2_jump_cutoff_value : float = 0.4
var p2_swing_impact : int = 300

## ON READY NOTATION VAR
@onready var animation = $AnimatedSprite2D
@onready var hitbox = $Hitbox/CollisionShape2D

func _ready():
	$Hitbox.body_entered.connect(_on_hit_box_body_entered)
	animation.animation_finished.connect(_on_animation_finished)
	animation.flip_h = true

func _physics_process(delta):
	# gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# p2_jump
	## For Double p2_jump remove  and is_on_floor():
	if Input.is_action_just_pressed("p2_jump") and is_on_floor():
		print("velocity .y  PULO=",velocity.y)
		velocity .y = p2_jump_FORCE
		animation.play("jump")
		
	if Input.is_action_just_released("p2_jump"):
		velocity.y *= p2_jump_cutoff_value
		
	#Double-p2_jump
	if Input.is_action_just_pressed("p2_jump") and not is_on_floor():
		print("velocity .y  PULO DUPLO=",velocity.y)
		velocity .y = p2_jump_FORCE
		animation.play("jump")
		
		
	# p2_swing
	if Input.is_action_just_pressed("p2_swing"):
		hitbox.disabled = false
		animation.play("swing")
		

	# movimento horizontal
	var direction = Input.get_axis("p2_left", "p2_right")
	
	if Input.is_action_pressed("p2_run") and direction != 0:
		velocity.x = direction * SPEED * 2
	else:
		velocity.x = direction * SPEED
	
		
	
	# flip do sprite
	if direction != 0:
		animation.flip_h = direction < 0
		hitbox.position.x = abs(hitbox.position.x) * direction
	
	# animacoes
# animacoes
	if animation.animation == "swing" and animation.is_playing():
		pass  # deixa p2_swing terminar
	elif animation.animation == "jump" and animation.is_playing():
		pass  # deixa p2_jump terminar
	elif not is_on_floor():
		pass  # no ar, não troca animacao
	elif Input.is_action_pressed("p2_run") and direction != 0:
		animation.play("p2_run")
	elif direction != 0:
		animation.play("walk")
	else:
		animation.play("idle")
	
	
	move_and_slide()

func _on_animation_finished():
	if animation.animation == "swing":
		hitbox.disabled = true

func _on_hit_box_body_entered(body):
	if body == self:
		return
	
	if body.name == "Ball":
		var direction_x = -1 if animation.flip_h else 1
		await get_tree().create_timer(0.2).timeout
		body.apply_impulse(Vector2(direction_x * p2_swing_impact, -200))
		body.hit_effect()
		
		#Attempt to add an slight screenshake at the impact
		Utils.shake(2.0)
		
		hitbox.set_deferred("disabled", true)
