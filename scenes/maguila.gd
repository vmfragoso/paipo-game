extends RigidBody2D


var _player

func start(pos: Vector2, player):
	global_position = pos
	_player = player

func _ready():
	print("MAGUILA READY")
	linear_velocity = Vector2(0, -200)
	await get_tree().create_timer(0.5).timeout
	$AudioStreamPlayer.play()
	await get_tree().create_timer(3.0).timeout
	queue_free()
	_player.maguila_ativo = false
