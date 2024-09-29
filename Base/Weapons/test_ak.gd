extends Node2D

var can_shot = true
@export var dmg = 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
@rpc("call_local")
func shot_snd():
	$shot_snd.play()
	$AnimationPlayer.play("shot_light")
func shot(owner):
	#print(multiplayer.get_unique_id(),is_multiplayer_authority())
	if can_shot:
		
		if is_multiplayer_authority():
			GG.rpc_id(1,"mp_send_shot",$from.global_position,$to.global_position,owner,dmg)
			can_shot = false
			rpc("shot_snd")
			#Не делайте так потом переделаю
			$Timer.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	can_shot = true
	pass # Replace with function body.
