extends Node2D
var map = 0
var peer
var player_scene = preload("res://Base/Player.tscn") 
var map_scene = preload("res://Maps/dm_fancy/dm_fancy.tscn")
var bullet_scene = preload("res://Base/Weapons/test_bullet.tscn")
var res_vfx_scene = preload("res://Base/VFX/vfx_respawn.tscn")
var connected = false
var local_player_init = false
@rpc("call_remote","any_peer")
func respawn(player):
	player = $Players.get_node(str(player))
	player.alive = true
	player.hp = 100
	#Spawns TODO Сделать нормально
	var mapspwn = $MPMap.get_child(0).get_node("Spawns")
	#print(player.global_position)
	#$Players.add_child(player)
	player.global_position = mapspwn.get_child(randi_range(0,mapspwn.get_child_count() - 1)).global_position
	print(player.global_position)
	var vfx_resp = res_vfx_scene.instantiate()
	vfx_resp.global_position = player.global_position
	$DinObjects.add_child(vfx_resp)
	GG.send_chat("[color=yellow]"+str(player.name)+"[/color] появился")
func spawn_bullet(from,to,owner,dmg):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = from
	bullet.go_to = to
	bullet.dmg = dmg
	bullet.by = owner
	bullet.name = str(randi_range(0,9999999999))
	$DinObjects.add_child(bullet,1)
func spawn_map():
	var smap = map_scene.instantiate()
	$MPMap.add_child(smap)


#WSTEST

func create_server_ws():	
	peer = WebSocketMultiplayerPeer.new()
	GG.slog("Создание сервера WS")
	peer.create_server(GG.mp_port)
	init_server(peer)
	pass
func create_server_wss():
	var key = load("/srv/key.key")
	var crt = load("/srv/cert.crt")
	var tls = TLSOptions.server(key,crt)
	peer = WebSocketMultiplayerPeer.new()
	GG.slog("Создание сервера WSS")
	if crt.save_to_string() :
		GG.slog("CRT OK")
	else:
		GG.slog("CRT BAD")
	if key.save_to_string() :
		GG.slog("KEY OK")
	else:
		GG.slog("KEY BAD")
	var err = peer.create_server(GG.mp_port,"*",tls)
	if err == OK:
		GG.slog("PEER OK")
		init_server(peer)
	else:
		GG.slog("Сервер не создан")
		push_error(err)
	pass
func join_client_wss():
	peer = WebSocketMultiplayerPeer.new()
	GG.slog("Подключение WSS к "+ GG.mp_ip)
#	var cert = load("res://cert.crt")
#	var tls = TLSOptions.client(cert)
	var err = peer.create_client("wss://"+GG.mp_ip+":"+str(GG.mp_port))
#	print(tls)
	if err == OK:
		init_clinet(peer)
	else:
		GG.slog("Подключение WSS к "+ GG.mp_ip+" завершилось с ошибкой")
		push_error(err)	
func join_client_ws():
	peer = WebSocketMultiplayerPeer.new()
	GG.slog("Подключение WS к "+ GG.mp_ip)
	peer.create_client("ws://"+GG.mp_ip+":"+str(GG.mp_port))
	init_clinet(peer)

#-----
func init_server(peer):
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_player_dis)
	spawn_map()
	hide_ls()
	GG.slog("Сервер создан")
	GG.MPDEBUG["PEERID"] = multiplayer.get_unique_id()	
func create_server():
	peer = ENetMultiplayerPeer.new()
	GG.slog("Создание сервера ENET")
	peer.create_server(GG.mp_port)
	init_server(peer)
	#_add_player()
func hide_ls():
	connected = true
	GG.MPDEBUG["PEERID"] = multiplayer.get_unique_id()	
	GG.emit_signal("need_ls",false)
func init_clinet(peer):
	multiplayer.multiplayer_peer = peer
	GG.slog("Init client")
	$StrangeThings/ConnectTimerWait.start()
	multiplayer.connected_to_server.connect(hide_ls)

func join_client():
	peer = ENetMultiplayerPeer.new()
	GG.slog("Подключение ENET к "+ GG.mp_ip)
	peer.create_client(GG.mp_ip,GG.mp_port)
	init_clinet(peer)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GG.emit_signal("need_ls",true)
	GG.slog("MPGame создана MP_STATE = "+ str(GG.mp_state))
	GG.connect("mp_shotfired",spawn_bullet)
	GG.connect("mp_send_damage_pipe",damage_controler)
	GG.connect("mp_respawn_pipe",respawn)
	if GG.mp_state == 0:
		create_server()
	elif GG.mp_state == 1:
		join_client()
	elif GG.mp_state == 10:
		create_server_ws()
	elif GG.mp_state == 11:
		join_client_ws()
	elif GG.mp_state == 12:
		create_server_wss()
	elif GG.mp_state == 13:
		join_client_wss()
	pass # Replace with function body.


func damage_controler(by,to,dmg):
	if multiplayer.is_server():
		#print("Damagecntr",by,"|",to,"|",dmg)
		#TODO Вынести в отельную функцию
		if $Players.has_node(str(by)):
			var damaged_node = $Players.get_node(str(to))
			damaged_node.hp -= dmg
			if damaged_node.hp <=0:
				damaged_node.alive = false
				damaged_node.dead()
				
				GG.rpc_id(damaged_node.name.to_int(),"client_showDS",damaged_node.get_node("RespTimer").wait_time)
				GG.send_chat("[color=green]"+str(by)+"[/color] убил [color=red]"+str(to)+"[/color]")
		pass

@rpc("any_peer","call_remote","unreliable")
func get_input(id,indir,mouse_pos,input_shot):
	$Players.get_node(str(id)).input_direction = indir
	$Players.get_node(str(id)).mouse_pos = mouse_pos
	$Players.get_node(str(id)).input_shot = input_shot

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#DEBUG
	GG.MPDEBUG["FPS"] = Engine.get_frames_per_second()   
	$Debug/CanvasLayer/Control/VBoxContainer/Deb.text = str(JSON.stringify(GG.MPDEBUG,"\t"))
	$Debug/CanvasLayer/Chat/ChatBox.text = GG.mp_synchat
	#print(JSON.stringify(GG.MPDEBUG))
	if !GG.is_ui_block and local_player_init:
		_local_input()
		$MPCam/Ch.global_position = get_global_mouse_position()
	pass
	
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	#Spawns TODO Сделать нормально
	var mapspwn = $MPMap.get_child(0).get_node("Spawns")

	#print(player.global_position)
	$Players.add_child(player)
	player.global_position = mapspwn.get_child(randi_range(0,mapspwn.get_child_count() - 1)).global_position
	#print(player.global_position)
	GG.send_chat(str(id)+ " подключен")

func _player_dis(id):
	GG.send_chat(str(id) + " отключился")
	$Players.get_node(str(id)).queue_free()

func _on_connect_timer_wait_timeout() -> void:
	if !connected:
		GG.slog("Нет ответа от сервера... Отключение через 5 секунд")
		$StrangeThings/DisconnectTimer.start()
	pass # Replace with function body.


func _on_dissconect_timer_timeout() -> void:
	multiplayer.multiplayer_peer = null
	GG.slog("Отключен")
	hide_ls()
	$".".queue_free()
	pass # Replace with function body.

func _local_input():
	rpc_id(1,"get_input",str(multiplayer.get_unique_id()),
	Input.get_vector("mov_left", "mov_right", "mov_up", "mov_down"),
	get_global_mouse_position(),
	Input.is_action_pressed("shot")
	)

func _on_player_spawner_spawned(node: Node) -> void:
	#InitLocalPlayer
	if node.name == str(multiplayer.get_unique_id()):
		$MPCam.follow_node = node
		rpc_id(1,"respawn",str(multiplayer.get_unique_id()))
		local_player_init = true
	pass # Replace with function body.
