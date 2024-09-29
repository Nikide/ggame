extends CharacterBody2D
@export var speed = 400
@export var alive = false
@export var input_direction = Vector2.ZERO
@export var mouse_pos = Vector2.ZERO
@export var input_shot = false
@export var hp = 100

func _ready() -> void:
	print(is_multiplayer_authority())
	if name != str(multiplayer.get_unique_id()):
		$m_pointer.hide()	
func _enter_tree() -> void:
	set_multiplayer_authority(1)

func dead():
	$RespTimer.start()

func is_posi(val) -> bool: #ну а хуле нет то
	if val > 0:
		return true
	else:
		return false

func get_input():
	#$Camera2D.enabled = is_multiplayer_authority()
	 # Input.get_vector("mov_left", "mov_right", "mov_up", "mov_down")
	
	if input_shot:
		#print("Input",multiplayer.get_unique_id())
		$Weapon.get_child(0).shot(name)
	velocity = input_direction * speed
func player_process(delta):
	#Бля ну я и проггер ебать
	if velocity != Vector2.ZERO:
		$AnimatedSprite2D3.play("default")
	else:
		$AnimatedSprite2D3.stop()
		$AnimatedSprite2D3.frame = 0
	if $m_pointer.global_position.distance_to(mouse_pos) > 8:
		$m_pointer.global_position +=  ($m_pointer.global_position.direction_to(mouse_pos) * 300) * delta
	#print($m_pointer.global_position.distance_to(mouse_pos))
	#Strange way to head rotate
	#$Head.look_at($m_pointer.global_position)
	#$Weapon.look_at($m_pointer.global_position)
	$Head.look_at(mouse_pos)
	$Weapon.look_at(mouse_pos)
	var left = is_posi($Head.global_position.direction_to(mouse_pos).x)
	if left :
		$Head.global_rotation = clamp($Head.global_rotation,-PI/4,PI/4)
		$Head.scale = Vector2(1,1)
		$Weapon.scale = Vector2(1,1)
		$AnimatedSprite2D3.flip_h = false
	else:
		$Head.global_rotation = clamp($Head.global_rotation,-PI/4,PI/4)
		$Head.scale = Vector2(-1,1)
		$Weapon.scale = Vector2(1,-1)
		$AnimatedSprite2D3.flip_h = true
#TODO сделать нормально		
func checker():
	if input_direction != Vector2.ZERO:
		if !$foot.playing:
			$foot.pitch_scale = randf_range(0.95,1.05)
			$foot.play()
func _physics_process(delta):
	$HPBar.value = hp
	#print(is_multiplayer_authority(),multiplayer.get_unique_id())
	if alive:
		checker()
		visible = true
		$CollisionShape2D.disabled = false
	else:
		$CollisionShape2D.disabled = true
		visible = false
	if is_multiplayer_authority():
		if alive:
			get_input()
			player_process(delta)
	if multiplayer.is_server():	
		move_and_slide()


func _on_resp_timer_timeout() -> void:
	GG.emit_signal("mp_respawn_pipe",name)
	pass # Replace with function body.
