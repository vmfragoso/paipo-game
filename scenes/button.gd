extends StaticBody2D
var maguila_ativo := false
var Maguila = preload("res://scenes/maguila.tscn")
@onready var hitbox = $PressColisition/RedButtonShape

func _on_hit_box_body_entered(body, matrix_ativo: bool):
	if maguila_ativo || body == self:
		return

	print("Entrou no botao")
	self.get_node("AnimatedSprite2D").play("pressed") 
	
	var maguila = Maguila.instantiate()
	get_tree().current_scene.add_child(maguila)
	if matrix_ativo:
		maguila.start(Vector2(400, 600),self, 0.75)
	else:
		maguila.start(Vector2(400, 600),self, 1) 
	print(body.global_position.x)
