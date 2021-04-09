extends KinematicBody2D

const MAX_SPEED = 80
const ACCELERATION = 700
const FRICTION = 800

var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE

func _ready():
	animationTree.active = true

func _process(delta):
	
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			pass
		ATTACK:
			attack_state(delta)

remote func _set_position(pos):
	global_transform.origin = pos

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationState.travel("Run")
		
		velocity = velocity.move_toward(MAX_SPEED * input_vector, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	if input_vector != Vector2():
			if is_network_master():
				velocity = move_and_slide(velocity)
			rpc_unreliable("_set_position",global_transform.origin)
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func attack_animation_finished():
	state = MOVE
