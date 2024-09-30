extends CharacterBody2D
@export var speed = 400
@export var alive = false
@export var input_direction = Vector2.ZERO
@export var mouse_pos = Vector2.ZERO
@export var action_1 = false
var can_act = true
@export var input_shot = false
@export var hp = 100
@export var nickname = ""
@export var action_point = 100

#test_acting
var _c_act1spd = 0
var _c_actmaxspd = 6000
###


func _ready() -> void:
	print(is_multiplayer_authority())
	if name != str(multiplayer.get_unique_id()):
		$m_pointer.hide()
	else:
		$AudioListener2D.make_current()
		pass
func _enter_tree() -> void:
	set_multiplayer_authority(1)
@rpc("any_peer")
func act_1_efect():
	$act_1.emitting = true
	$dash_snd.play()
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
	velocity = input_direction * (speed + _c_act1spd)
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
func act_1():
	if input_direction and action_point > 40:
		rpc("act_1_efect")
		print(velocity)
		_c_act1spd = _c_actmaxspd
		action_point = clamp(action_point - 40,0,100)
func _physics_process(delta):
	$HPBar.value = hp
	$Nickname.text = nickname
	#print(is_multiplayer_authority(),multiplayer.get_unique_id())
	if alive:
		checker()
		visible = true
		$CollisionShape2D.disabled = false
	else:
		$CollisionShape2D.disabled = true
		visible = false


		pass
func not_fps_input():
	if action_1:
		act_1()
	if !(_c_act1spd <= 0):
		_c_act1spd -= 500
	else:
		_c_act1spd = 0
func _process(delta: float) -> void:

	if is_multiplayer_authority():
		if alive:
			
			get_input()
			player_process(delta)
	if multiplayer.is_server():
		if alive:
			not_fps_input()
			move_and_slide()
	pass
func _on_resp_timer_timeout() -> void:
	GG.emit_signal("mp_respawn_pipe",name)
	pass # Replace with function body.


func _on_one_sec_timeout() -> void:
	if multiplayer.is_server():
		if action_point != 100:
			action_point = clamp(action_point + 10,0,100)
	pass # Replace with function body.
