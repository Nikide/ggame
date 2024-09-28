extends Node2D

@export var go_to : Vector2
@export var b_speed = 1000
var by = null
var dmg = null
var _to : Vector2
var _tick = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_to = global_position.direction_to(go_to)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	global_position += (_to* b_speed) * delta
	_tick +=1
	if _tick >=500:
		queue_free()
	#	print("Despawn ",name)
	#print(global_position,name,multiplayer.get_unique_id())
	pass


func _on_give_damage_body_entered(body: Node2D) -> void:
	#print("Bulet ", body)
	if str(by) != body.name:
		if body.has_meta("can_damage"):
			#Бля ну пиздец нахуй так неткод писать ебанутый нахуй
			#TODO Сделать нормалный посыл дамага
			GG.emit_signal("mp_send_damage_pipe",by,body.name,dmg)
		queue_free()
	pass # Replace with function body.
