extends Node

var log = ""
var mp_state = 0
var mp_ip = "localhost"
var mp_port = 14880
signal need_ls
signal mp_shotfired(from,to)
signal mp_send_damage_pipe(by,to,dmg)
signal mp_respawn_pipe(who)
signal cl_ds(time)
signal mp_nickname_pipe(id,nick)
var _mp_chat_text = ""
var mp_synchat = ""
var mp_nickname = "nickname"
var is_ui_block = false
var MPDEBUG = {
	"SERVERTIME": 0,
	"SRVDELTA": 0
}

func test_ping(time):
	return   Time.get_ticks_msec() - time

@rpc("any_peer")
func client_showDS(time):

	if multiplayer.get_remote_sender_id() == 1:
		emit_signal("cl_ds",time)
@rpc("any_peer")
func send_nickname(str):
	print("get nickname from ",multiplayer.get_remote_sender_id())
	emit_signal("mp_nickname_pipe",multiplayer.get_remote_sender_id(),str)
func send_chat(text):
	var time = Time.get_time_dict_from_system()
	var format_time =  "%02d:%02d:%02d" % [time.hour, time.minute,time.second]
	_mp_chat_text += format_time+" "+text+"\n"
@rpc("any_peer")
func sync_chat(chat):
	mp_synchat = chat
@rpc("any_peer")
func send_server_time(time):
	
	MPDEBUG["SRVDELTA"] = str(time-int(MPDEBUG["SERVERTIME"]))
	MPDEBUG["SERVERTIME"] = str(time)

func slog(txt : String):
	log += "\n"+txt
	#printraw(txt,'\n') #fir console
	print(txt)
	pass
# Called when the node enters the scene tree for the first time.

#multiplayer fun

@rpc("any_peer","call_local")
func mp_send_shot(from,to,owner,dmg):
#	print("Shot",multiplayer.get_unique_id())
	emit_signal("mp_shotfired",from,to,owner,dmg)
	

func _ready() -> void:
	slog("GG init")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if multiplayer.multiplayer_peer:
		if multiplayer.is_server():
			rpc("sync_chat",_mp_chat_text)
			rpc("send_server_time",Time.get_ticks_msec())
		pass
