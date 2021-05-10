extends KinematicBody2D

const MAX_SPEED = 80
const ACCELERATION = 700
const FRICTION = 800

var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var tween = $Tween

puppet var puppet_position = Vector2(0,0) setget puppet_position_set 
puppet var puppet_velocity = Vector2()

var state = MOVE

enum {
	MOVE,
	ROLL,
	ATTACK
}

func _ready():
	animationTree.active = true

func _process(delta):
	if is_network_master():
		match state:
			MOVE:
				move_state(delta)
			ROLL:
				pass
			ATTACK:
				attack_state(delta)
	else:
		if not tween.is_active():
			move_and_slide(puppet_velocity)

func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_velocity", velocity)

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self,"global_position", global_position,puppet_position,0.1)
	tween.start()

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
	
	velocity = move_and_slide(velocity)
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func attack_animation_finished():
	state = MOVE



