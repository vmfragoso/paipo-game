extends CharacterBody2D

#CONS
const SPEED = 130.0
const JUMP_FORCE = -400
const GRAVITY = 800
const MATRIX_HOLD = 1.5

##PRIVATE VARIABLES
var matrix_ativo := false
var jump_cutoff_value : float = 0.4
var swing_impact : int = 300
var swing_hold_time := 0.0

## ON READY NOTATION VAR
@onready var animation = $AnimatedSprite2D
@onready var hitbox = $Hitbox/CollisionShape2D

func _ready():
	$Hitbox.body_entered.connect(_on_hit_box_body_entered)
	animation.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	# gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# jump
	## For Double Jump remove  and is_on_floor():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		print("velocity .y  PULO=",velocity.y)
		velocity .y = JUMP_FORCE
		animation.play("jump")
		
	if Input.is_action_just_released("jump"):
		velocity.y *= jump_cutoff_value
		
	#Double-jump
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		print("velocity .y  PULO DUPLO=",velocity.y)
		velocity .y = JUMP_FORCE
		animation.play("jump")
		
		
	# swing
	if Input.is_action_just_pressed("swing"):
		swing_hold_time = 0.0
		
	if Input.is_action_pressed("swing"):
		swing_hold_time += delta
		print("swing_hold_time: ", swing_hold_time, "s")
		animation.play("walk")
		
	if Input.is_action_just_released("swing"):
		if swing_hold_time >= MATRIX_HOLD:
			matrix_ativo = true
		else:
			matrix_ativo = false
		
		hitbox.disabled = false
		animation.play("swing")
		

	# movimento horizontal
	var direction = Input.get_axis("left-move", "right-move")
	
	if Input.is_action_pressed("run") and direction != 0:
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
		pass  # deixa swing terminar
	elif animation.animation == "jump" and animation.is_playing():
		pass  # deixa jump terminar
	elif not is_on_floor():
		pass  # no ar, não troca animacao
	elif Input.is_action_pressed("run") and direction != 0:
		animation.play("run")
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
		body.apply_impulse(Vector2(direction_x * swing_impact, -200))
		body.hit_effect(matrix_ativo)
		
		#Attempt to add an slight screenshake at the impact
		Utils.shake(2.0)
		
		hitbox.set_deferred("disabled", true)
