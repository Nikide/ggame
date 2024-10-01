extends Node2D
#MOB CONTROLLER
enum {STATE_IDLE,STATE_FOLLOW}
@export var trigger_area : Area2D
@export var speed = 5000
@export var hp = 100
var _follow : Node2D
var _state = STATE_IDLE
var _mob : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_mob = get_parent()
	if trigger_area:
		trigger_area.connect("body_entered",do_trigger)
	pass # Replace with function body.


func do_trigger(body):
	if body.has_meta("is_player"):
		_follow = body
		_state = STATE_FOLLOW
	pass

func _physics_process(delta: float) -> void:
	if _state == STATE_IDLE:
		_mob.velocity = Vector2.ZERO
	if _state == STATE_FOLLOW:
		if _follow:
			_mob.velocity = _mob.global_position.direction_to(_follow.global_position) * speed * delta
	_mob.move_and_slide()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
