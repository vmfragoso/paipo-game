extends CanvasLayer

@onready var bar = $Container/HealthBar
var tween_hp: Tween



func set_hp(current_hp: int, max_hp: int): 
	print("HUD: set_hp chamado! current=", current_hp, " max=", max_hp)
	print("HUD: bar existe? ", bar != null)
	if tween_hp and tween_hp.is_valid():
		tween_hp.kill()
			
	tween_hp = create_tween()
	tween_hp.tween_property(bar, "value", current_hp, 0.3)
