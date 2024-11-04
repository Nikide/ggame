extends Node2D
#MOB CONTROLLER
enum {STATE_IDLE,STATE_FOLLOW,SHOT}
@export var trigger_area : Area2D
@export var speed = 5000
@export var hp = 100
var _follow : Node2D
var _state = STATE_IDLE
var _mob : CharacterBody2D
var wep : Node2D
# Called when the node enters the scene tree for the first time.
@rpc("any_peer")
func shot():
	wep.get_child(0).shot(name)
func _ready() -> void:
	_mob = get_parent()
	if trigger_area:
		trigger_area.connect("body_entered",do_trigger)
	pass # Replace with function body.
func weapon_con():
	if get_parent().has_node("Weapon"):
		wep = get_parent().get_node("Weapon")
		if _follow:
			wep.look_at(_follow.global_position)
		if _state == SHOT:
			rpc("shot")
func do_trigger(body):
	if body.has_meta("is_player"):
		_follow = body
		_state = STATE_FOLLOW
	pass
var is_can_shoot = false
func _physics_process(delta: float) -> void:
	weapon_con()
	if _follow:
		#if global_position.distance_to(_follow.global_position) > 1000:
		
			#_state = STATE_IDLE
			#is_can_shoot = false
			#_follow = null
		if global_position.distance_to(_follow.global_position) < 500:
			_state = STATE_IDLE
			is_can_shoot = true
		else:
			_state = STATE_FOLLOW
			is_can_shoot = true
	if is_can_shoot:
		rpc("shot")
	if _state == STATE_IDLE:
		_mob.velocity = Vector2.ZERO
	if _state == STATE_FOLLOW :
		if _follow:
			_mob.velocity = _mob.global_position.direction_to(_follow.global_position) * speed * delta
	else:
		_mob.velocity = Vector2.ZERO
	
	_mob.move_and_slide()
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
