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
var _mp_chat_text = "-----CHAT INIT-----\n"
var mp_synchat = ""
var is_ui_block = false
var MPDEBUG = {
	"SERVERTIME": 0,
	"PING": 0
}
@rpc("any_peer")
func client_showDS(time):

	if multiplayer.get_remote_sender_id() == 1:
		emit_signal("cl_ds",time)
			
func send_chat(text):
	var time = Time.get_time_dict_from_system()
	_mp_chat_text += "["+str(time.hour)+":"+str(time.minute)+":"+str(time.second)+"] "+text+"\n"
@rpc("any_peer")
func sync_chat(chat):
	mp_synchat = chat
@rpc("any_peer")
func send_server_time(time):
	
	MPDEBUG["PING"] = str(time-int(MPDEBUG["SERVERTIME"]))
	MPDEBUG["SERVERTIME"] = str(time)

func slog(txt : String):
	log += "\n"+txt
	printraw(txt,'\n') #fir console
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
