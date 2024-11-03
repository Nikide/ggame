extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$AudioStreamPlayer2D.play()
	$AnimatedSprite2D.play("default")
	$AnimationPlayer.play("resp")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_audio_stream_player_2d_finished() -> void:
	#queue_free()
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if multiplayer.is_server(): queue_free()
	pass # Replace with function body.
