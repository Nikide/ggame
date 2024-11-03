extends Node2D

var debug_mp = preload("res://Base/MPGame.tscn")
var LD : Node
var MENU : Node
var IS_MP = false
# Called when the node enters the scene tree for the first time.
func showDS(time = 10):
	$UI/CanvasLayer/DeadScreen.show()
	$UI/CanvasLayer/DeadScreen/AnimationPlayer.play("show")
	$UI/CanvasLayer/DeadScreen/DSTimer.wait_time = time
	$UI/CanvasLayer/DeadScreen/VBoxContainer/Label2.text = "Возраждение через " + str(time) + " секунд"
	$UI/CanvasLayer/DeadScreen/DSTimer.start()
	pass
func _ready() -> void:
	#$UI/CanvasLayer/Loading/AnimatedSprite2D.play("default")
	Engine.max_fps = 60
	LD = $UI/CanvasLayer/Loading
	MENU = $UI/CanvasLayer/Menu
	LD.hide()
	GG.connect("need_ls",need_ls)
	GG.connect("cl_ds",showDS)
	if !OS.is_debug_build():
		$UI/CanvasLayer/Menu/debug.hide()
	if OS.has_feature("dedicated_server"):
		GG.mp_state = GG.CONMODE.WSS_SERVER
		var mp = debug_mp.instantiate()
		add_child(mp)
		MENU.hide()	
		
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func need_ls(state : bool):
	if state:
		LD.show()
	else:
		LD.hide()

func _process(delta: float) -> void:
	$UI/CanvasLayer/Loading/VBoxContainer2/log.text = GG.log
	IS_MP = $".".has_node("MPGame")
	menu()
	GG.is_ui_block = MENU.visible
	pass
func menu():
	if MENU.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if IS_MP:
		$UI/CanvasLayer/Menu/BG.color.a = 0.8
	else:
		$UI/CanvasLayer/DeadScreen.hide()
		$UI/CanvasLayer/Menu/BG.color.a = 1
		MENU.show()
	if Input.is_action_just_pressed("menu"):
		if IS_MP:
			if MENU.visible:
				MENU.hide()
			
			else:
				MENU.show()
func start_mpgame():
	var mp = debug_mp.instantiate()
	GG.mp_nickname = $UI/CanvasLayer/Menu/TEMP/HBoxContainer2/LineEdit.text
	add_child(mp)
	MENU.hide()

func _on_db_host_pressed() -> void:
	GG.mp_state = GG.CONMODE.ENET_SERVER
	start_mpgame()
#	LD.show()
	pass # Replace with function body.


func _on_db_join_pressed() -> void:
	GG.mp_state = GG.CONMODE.ENET_CLIENT
	start_mpgame()
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	if IS_MP:
		get_node("MPGame").queue_free()
		multiplayer.multiplayer_peer = null
	else:
		get_tree().quit() 
	pass # Replace with function body.


func _on_ds_timer_timeout() -> void:
	$UI/CanvasLayer/DeadScreen.hide()
	
	pass # Replace with function body.


func _on_db_host_ws_pressed() -> void:
	GG.mp_state = GG.CONMODE.WS_SERVER

	start_mpgame()
	pass # Replace with function body.


func _on_db_join_ws_pressed() -> void:
	GG.mp_state = GG.CONMODE.WS_CLIENT

	start_mpgame()
	pass # Replace with function body.


func _on_temp_join_pressed() -> void:
	GG.mp_state = GG.CONMODE.WSS_CLIENT
	GG.mp_ip = $UI/CanvasLayer/Menu/TEMP/HBoxContainer/IP.text
	GG.mp_port = $UI/CanvasLayer/Menu/TEMP/HBoxContainer/PORT.text.to_int()
	start_mpgame()
	pass # Replace with function body.


func _on_line_edit_text_changed(new_text: String) -> void:
	GG.mp_nickname = new_text
	pass # Replace with function body.


func _on_db_wrtc_host_pressed() -> void:
	GG.mp_state = GG.CONMODE.WRTC_SERVER

	start_mpgame()
	pass # Replace with function body.


func _on_db_wrtc_join_pressed() -> void:
	GG.mp_state = GG.CONMODE.WRTC_CLIENT

	start_mpgame()
	pass # Replace with function body.
