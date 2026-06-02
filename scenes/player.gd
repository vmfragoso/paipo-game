extends CharacterBody2D
@export var player_id := 1

#CONS
const SPEED = 130.0
const JUMP_FORCE = -400
const GRAVITY = 800
const MATRIX_HOLD = 1.5
const INITIAL_SWING_FORCE = 150

##PRIVATE VARIABLES
var matrix_ativo := false
var jump_cutoff_value : float = 0.4
var swing_impact := INITIAL_SWING_FORCE
var swing_hold_time := 0.0

## ON READY NOTATION VAR
@onready var animation = $AnimatedSprite2D
@onready var hitbox = $Hitbox/CollisionShape2D

func _ready():
	$Hitbox.body_entered.connect(_on_hit_box_body_entered)

func action(action_name: String) -> String:
	if player_id == 1:
		return action_name
	return "p2_" + action_name

func _physics_process(delta):
	# gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# jump
	## For Double Jump remove  and is_on_floor():
	if Input.is_action_just_pressed(action("jump")) and is_on_floor():
		print("velocity .y  PULO=",velocity.y)
		velocity .y = JUMP_FORCE
		animation.play("jump")
		
	if Input.is_action_just_released(action("jump")):
		velocity.y *= jump_cutoff_value
		
	#Double-jump
	if Input.is_action_just_pressed(action("jump")) and not is_on_floor():
		print("velocity .y  PULO DUPLO=",velocity.y)
		velocity .y = JUMP_FORCE
		animation.play("jump")
		
	# swing
	if Input.is_action_just_pressed(action("swing")):
		swing_hold_time = 0.0
		swing_impact = INITIAL_SWING_FORCE
	if Input.is_action_pressed(action("swing")):
		swing_hold_time += delta
		swing_impact += 5
		print("swing_hold_time: ", swing_hold_time, "s")
		animation.play("walk")
		
	if Input.is_action_just_released(action("swing")):
		if swing_hold_time >= MATRIX_HOLD:
			matrix_ativo = true
		else:
			matrix_ativo = false
		
		#hitbox.disabled = false
		animation.play("swing")
		

	# movimento horizontal
	var direction = Input.get_axis(action("left"), action("right"))
	
	if Input.is_action_pressed(action("run")) and direction != 0:
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
	elif Input.is_action_pressed(action("run")) and direction != 0:
		animation.play("run")
	elif direction != 0:
		animation.play("walk")
	else:
		animation.play("idle")
	
	
	move_and_slide()

func _process(delta):
	if animation.animation == "swing":
		hitbox.disabled = not (animation.frame >= 3 and animation.frame <= 4)
	else:
		hitbox.disabled = false

func _on_hit_box_body_entered(body):
	var direction_x = -1 if animation.flip_h else 1
	
	if body == self:
		return
	
	if (body.name == "Ball" or body.name.contains("Player")) and animation.animation == "swing":
		print(body.name, " ", animation.animation)
		print(direction_x * swing_impact)
		body.apply_impulse(Vector2(direction_x * swing_impact, body.position.y*-1))
		body.hit_effect(matrix_ativo)
		
	if body.name.contains("button"):
		body._on_hit_box_body_entered(self, matrix_ativo)
		
	if body.name.contains("Player"):
		body.apply_impulse(Vector2(direction_x * 1, body.position.y*-1))
