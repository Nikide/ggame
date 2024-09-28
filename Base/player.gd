extends CharacterBody2D
@export var speed = 600
@export var alive = false
@export var input_direction = Vector2.ZERO
@export var mouse_pos = Vector2.ZERO
@export var input_shot = false
@export var hp = 100
func _ready() -> void:
	print(is_multiplayer_authority())
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
	if $m_pointer.global_position.distance_to(mouse_pos) > 10:
		$m_pointer.global_position +=  ($m_pointer.global_position.direction_to(mouse_pos) * 500) * delta
	#print($m_pointer.global_position.distance_to(mouse_pos))
	#Strange way to head rotate
	$Head.look_at($m_pointer.global_position)
	$Weapon.look_at($m_pointer.global_position)
	var left = is_posi($Head.global_position.direction_to($m_pointer.global_position).x)
	if left :
		$Head.global_rotation = clamp($Head.global_rotation,-PI/4,PI/4)
		$Head.scale = Vector2(1,1)
		$Weapon.scale = Vector2(1,1)
	else:
		$Head.global_rotation = clamp($Head.global_rotation,-PI/4,PI/4)
		$Head.scale = Vector2(-1,1)
		$Weapon.scale = Vector2(1,-1)
func _physics_process(delta):
	$HPBar.value = hp
	#print(is_multiplayer_authority(),multiplayer.get_unique_id())
	if alive:
		visible = true
		$CollisionShape2D.disabled = false
	else:
		$CollisionShape2D.disabled = true
		visible = false
	if is_multiplayer_authority():
		if alive:
			get_input()
			player_process(delta)
		
	move_and_slide()


func _on_resp_timer_timeout() -> void:
	GG.emit_signal("mp_respawn_pipe",name)
	pass # Replace with function body.
