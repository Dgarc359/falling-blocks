extends CharacterBody2D
const ALIVE_SPRITE = preload("res://assets/sprites/player-character/Sprite-0001.bmp")
const DEATH_SPRITE = preload("res://assets/sprites/death-sprite/death-sprite.bmp")

@onready var character_sprite = $Sprite2D
@onready var hurtbox = $Area2D
@onready var character_body_2d = $"."
@onready var character_collider = $CollisionShape2D
@onready var player_character_root_node = $".."
@onready var ui_manager = $Camera2D/CanvasLayer/UIManager

@onready var camera_canvas_layer = $Camera2D/CanvasLayer

@export var winning_conditions_are_met = false
@export var player_is_dead: bool = false
@export var SPEED = 300.0
const JUMP_VELOCITY = -400.0
var player_has_been_killed = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	if player_is_dead && not player_has_been_killed:
		kill_player()
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and not player_is_dead:
		velocity.y += gravity * delta

	# Handle jump.
	if (Input.is_action_just_pressed("up") || Input.is_action_just_pressed("jump")) and (is_on_floor() or player_is_dead):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var vertical_direction_down = Input.is_action_pressed("down")
	var vertical_direction_release = Input.is_action_just_released("down")
	var vertical_direction_up_release = Input.is_action_just_released("up")

	if vertical_direction_down and player_is_dead:
		velocity.y = -JUMP_VELOCITY
	if (vertical_direction_release or vertical_direction_up_release) && player_is_dead:
		velocity.y = 0

	move_and_slide()
	

func unkill():
	character_sprite.set_texture(ALIVE_SPRITE)
	character_body_2d.set_collision_layer_value(1, true)
	character_body_2d.set_collision_mask_value(1, true)
	player_has_been_killed = false
	player_is_dead = false
	player_character_root_node.player_died.emit(true, false)
	ui_manager.enable_death_ui(false)
	#player_died.emit(false, true)

func kill_player():
	character_sprite.set_texture(DEATH_SPRITE)
	character_body_2d.set_collision_layer_value(1, false)
	character_body_2d.set_collision_mask_value(1, false)
	player_has_been_killed = true
	player_is_dead = true
	player_character_root_node.player_died.emit(false, true)
	ui_manager.enable_death_ui(true)
	#player_died.emit(false, true)

func _on_area_2d_body_entered(body):
	if body is RigidBody2D:
		print("rigidbody hit")
		kill_player()
	
	pass # Replace with function body.


func player_won():
	if player_is_dead:
		print("player is dead and cannot win")
		return
	player_character_root_node.player_won.emit(false, true)
	winning_conditions_are_met = true
	ui_manager.enable_victory_ui(true)
	print("player won!")

func _on_area_2d_area_entered(area):
	if area.is_in_group("winning_tile"):
		player_won()
	pass # Replace with function body.
