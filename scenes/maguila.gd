extends RigidBody2D


var _player
var _matrix_ativo := false
func start(pos: Vector2, player, matrix_ativo: bool):
	global_position = pos
	_player = player
	_matrix_ativo = matrix_ativo

func _ready():
	print("MAGUILA READY")
	linear_velocity = Vector2(0, -200)
	await get_tree().create_timer(0.5).timeout
	
	if _matrix_ativo:
		$AudioStreamPlayer.pitch_scale = 0.75
	else:
		$AudioStreamPlayer.pitch_scale = 1
		
	$AudioStreamPlayer.play()
	await get_tree().create_timer(3.0).timeout
	queue_free()
	_player.maguila_ativo = false
