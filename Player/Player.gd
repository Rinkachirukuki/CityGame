extends KinematicBody2D

const MAX_SPEED = 80
const ACCELERATION = 700
const FRICTION = 800

var hp = 100 setget hp_set
var velocity = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

onready var tween = $Tween
onready var reload_timer = $Reload_timer
onready var rate_of_fire_timer = $Rate_of_fire_Timer
onready var hit_timer = $Hit_timer
onready var shoot_point = $Shoot_point

var can_shoot = true
var god_mode = true
var max_ammo = 3
var ammo = max_ammo

var is_reloading = false
var throw_delay = false

var player_shuriken = load("res://Entities/Player_shuriken.tscn")
var username_text = load("res://Player/Username/Username_text.tscn")

var username setget username_set
var username_text_instance = null

puppet var puppet_hp = 100 setget puppet_hp_set
puppet var puppet_position = Vector2(0,0) setget puppet_position_set 
puppet var puppet_velocity = Vector2()
puppet var puppet_username = "" setget puppet_username_set

puppet var puppet_input_vector = Vector2.ZERO


func _ready():
	get_tree().connect("network_peer_connected",self,"_network_peer_connected")
	
	username_text_instance = Global.instance_node_at_location(username_text, Persistent_nodes, global_position)
	username_text_instance.player_following = self
	
	animationTree.active = true
	
	yield(get_tree(), "idle_frame")
	
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = self
	
	god_mode = true
	
	Global.alive_players.append(self)

func _process(delta):
	if username_text_instance != null:
		username_text_instance.name = "username" + name
	
	if get_tree().has_network_peer() and is_network_master():
		move_state(delta)
		if can_shoot and not is_reloading and not throw_delay:
			if Input.is_action_pressed("FirstAttack"):
				rpc("instance_shuriken", get_tree().get_network_unique_id())
				
				ammo -= 1
				
				throw_delay = true
				rate_of_fire_timer.start()
				
				if ammo <= 0:
					is_reloading = true
					reload_timer.start()
			elif Input.is_action_pressed("SecondAttack"):
				rpc("instance_some_shurikens", get_tree().get_network_unique_id())
				
				ammo -= 3
				
				is_reloading = true
				reload_timer.start()
	else:
		if not tween.is_active():
			move_and_slide(puppet_velocity)
		
		if puppet_input_vector != Vector2.ZERO:
			animationTree.set("parameters/Idle/blend_position", puppet_input_vector)
			animationTree.set("parameters/Run/blend_position", puppet_input_vector)
			animationTree.set("parameters/Attack/blend_position", puppet_input_vector)
			animationState.travel("Run")
		else:
			animationState.travel("Idle")
	
	
	if get_tree().has_network_peer():
		if get_tree().is_network_server() and hp <= 0:
			if username_text_instance != null:
				username_text_instance.visible = false
			
			rpc("destroy")


func _on_Network_tick_rate_timeout():
	if get_tree().has_network_peer():
		if is_network_master():
			rset_unreliable("puppet_position", global_position)
			rset_unreliable("puppet_velocity", velocity)

sync func instance_shuriken(id):
	var player_shuriken_instance = Global.instance_node_at_location(player_shuriken, Persistent_nodes,shoot_point.global_position)
	player_shuriken_instance.name = "Shuriken" + name + str(Network.networked_object_name_index)
	player_shuriken_instance.set_network_master(id)
	player_shuriken_instance.player_rotation = shoot_point.get_local_mouse_position().angle()
	player_shuriken_instance.player_owner = id
	Network.networked_object_name_index += 1

sync func instance_some_shurikens(id):
	var player_shuriken_instance = Global.instance_node_at_location(player_shuriken, Persistent_nodes,shoot_point.global_position)
	player_shuriken_instance.name = "Shuriken" + name + str(Network.networked_object_name_index)
	player_shuriken_instance.set_network_master(id)
	player_shuriken_instance.player_rotation = shoot_point.get_local_mouse_position().angle() + 0.1
	player_shuriken_instance.player_owner = id
	Network.networked_object_name_index += 1
	
	player_shuriken_instance = Global.instance_node_at_location(player_shuriken, Persistent_nodes,shoot_point.global_position)
	player_shuriken_instance.name = "Shuriken" + name + str(Network.networked_object_name_index)
	player_shuriken_instance.set_network_master(id)
	player_shuriken_instance.player_rotation = shoot_point.get_local_mouse_position().angle()
	player_shuriken_instance.player_owner = id
	Network.networked_object_name_index += 1
	
	player_shuriken_instance = Global.instance_node_at_location(player_shuriken, Persistent_nodes,shoot_point.global_position)
	player_shuriken_instance.name = "Shuriken" + name + str(Network.networked_object_name_index)
	player_shuriken_instance.set_network_master(id)
	player_shuriken_instance.player_rotation = shoot_point.get_local_mouse_position().angle() - 0.1
	player_shuriken_instance.player_owner = id
	Network.networked_object_name_index += 1

sync func update_position(pos):
	global_position = pos
	puppet_position = pos

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self,"global_position", global_position,puppet_position,0.1)
	tween.start()

func username_set(new_value):
	username = new_value
	if get_tree().has_network_peer():
		if is_network_master() and username_text_instance != null:
			username_text_instance.text = username
			rset("puppet_username", username)

func puppet_username_set(new_value):
	puppet_username = new_value
	
	if not is_network_master() and username_text_instance != null:
		username_text_instance.text = puppet_username

func _network_peer_connected(id):
	rset_id(id, "puppet_username", username)
	

func move_state(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	input_vector = input_vector.normalized()
	
	if get_tree().has_network_peer():
		if is_network_master():
			rset("puppet_input_vector", input_vector)
	
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


func _on_Reload_timer_timeout():
	is_reloading = false
	ammo = max_ammo


func puppet_hp_set(new_value):
	puppet_hp = new_value
	
	if get_tree().has_network_peer():
		if not is_network_master():
			hp = puppet_hp

func hp_set(new_value):
	hp = new_value
	
	if get_tree().has_network_peer():
		if is_network_master():
			rset("puppet_hp", hp)


func _on_Hit_timer_timeout():
	modulate = Color (1,1,1,1)

func update_god_mode(god):
	god_mode = god



sync func hit_by_damager(damage):
	if not god_mode:
		hp -= damage
	modulate = Color(2,2,2,1)
	hit_timer.start()

sync func enable():
	hp = 100
	can_shoot = true
	god_mode = true
	
	username_text_instance.visible = true
	visible = true
	$CollisionShape2D.disabled = false
	$Hitbox/CollisionShape2D.disabled = false
	
	if get_tree().has_network_peer() and is_network_master():
		Global.player_master = self
	
	if not Global.alive_players.has(self):
		Global.alive_players.append(self)
	

sync func destroy():
	username_text_instance.visible = false
	visible = false
	$CollisionShape2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
	can_shoot = false
	
	Global.alive_players.erase(self) 
	
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = null

func _exit_tree():
	Global.alive_players.erase(self) 
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = null


func _on_Rate_of_fire_Timer_timeout():
	throw_delay = false
