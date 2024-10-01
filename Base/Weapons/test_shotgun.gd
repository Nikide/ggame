extends Node2D
@export var dmg = 15
var _can_shot = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
@rpc("any_peer")
func local_shot():
	$AnimationPlayer.play("shot")
func shot(own):
	if is_multiplayer_authority() and _can_shot:
		_can_shot = false
		$Timer.start()
		rpc("local_shot")
		GG.rpc_id(1,"mp_send_shot",$from.global_position,$to.global_position,own,dmg)
		GG.rpc_id(1,"mp_send_shot",$from.global_position,$to2.global_position,own,dmg)
		GG.rpc_id(1,"mp_send_shot",$from.global_position,$to3.global_position,own,dmg)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	_can_shot = true
	pass # Replace with function body.
