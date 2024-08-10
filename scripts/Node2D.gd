extends Node2D

@onready var node_2d = $"."
@onready var player_character = $"PlayerCharacter"

@export var width: int = 5
@export var height: int = 5
@export var block_spawn_elapsed_time: int = 3

@onready var time_since_last_spawn = 0
const VICTORY_TILE = preload("res://assets/sprites/victory-tile/victory-tile.bmp")
const wallblock_bmp = preload("res://assets/sprites/wall-block-02/wall.png")
const FALLING_BLOCK_01 = preload("res://assets/sprites/spikeball/spikeball.png")
const RIGID_2_KINEMATIC = preload("res://scenes/rigid_2_kinematic.tscn")
var player_is_dead: bool = false
var padding = 200
var player_initial_starting_position: Vector2

func _draw():
	create_game_map(width, height)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	player_initial_starting_position = player_character.position
	#pc_cam_control.add_child(death_ui)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if time_since_last_spawn > block_spawn_elapsed_time:
		spawn_falling_block(node_2d, width)
		time_since_last_spawn = 0

	time_since_last_spawn += delta
	
	pass

func spawn_falling_block(main_node, width):
	var start_pos = Vector2(padding + 32 * randi_range(1, width - 2), -50)
	var size = Vector2(32,32)
	
	print("spawning falling block")
	
	var rb2 = RIGID_2_KINEMATIC.instantiate()
	rb2.starting_pos = start_pos
	main_node.add_child(rb2)
	
	pass

func _on_win_condition_area_enter():
	print("win con area entered")

func create_win_condition_blocks(width):
	# left win condition block
	create_static_2d_object(
					node_2d,
					VICTORY_TILE,
					Vector2(padding, padding - 32),
					Vector2(padding, padding - 32),
					32,
					32,
					false,
					_on_win_condition_area_enter
				)
	
	#right win condition block
	create_static_2d_object(
					node_2d,
					VICTORY_TILE,
					Vector2(padding + (width -1) * 32,padding - 32),
					Vector2(padding + 32 * (width - 1), padding - 32),
					32,
					32,
					false,
					_on_win_condition_area_enter
				)
	pass

func create_game_map(width: int, height: int):
	print("creating game map")
	for y in range(height):
		for x in range(width):
			if block_should_be_created(x, y, width, height):
				create_static_2d_object(
					node_2d,
					wallblock_bmp,
					Vector2(padding + 32 * x,padding + 32 * y),
					Vector2(padding + 32 * x, padding + 32 * y)
				)
	create_win_condition_blocks(width)
	print("finished creating game map")

func block_should_be_created(x: int, y: int, width: int, height: int) -> bool:
	# leave the last row entirely
	# remove only the inner rows
	if y < height - 1 && x != 0 && x != width - 1:
		return false
	
	return true

func USELESS_EMPTY_FUNCTION() -> void:
	print("a slightly useless function was called")
	pass

func create_static_2d_object(
	parent_node: Node2D,
	sprite_bmp,
	start_point: Vector2 = Vector2(0,0), 
	end_point: Vector2 = Vector2(50, 50),
	width: int = 32,
	height: int = 32,
	is_collideable: bool = true,
	area_entered_callback: Callable = USELESS_EMPTY_FUNCTION,
):
	#var potentially_null_area = null
	# Create a new Shape
	var shape = RectangleShape2D.new()
	shape.set_size(Vector2(width,height))

	# Create a new collisionShape
	#if is_collideable:
	var collision_shape = CollisionShape2D.new()
	
	# Add the shape we created before to this collision shape
	collision_shape.set_shape(shape)
	collision_shape.set_position(collision_shape.position + start_point)

	# Create the StaticBody2D
	var static_body = StaticBody2D.new()
	# Add the CollisionShape we've created as child of the StaticBody
	if is_collideable:
		static_body.add_child(collision_shape)
	else:
		# make area 2d and set it to collision shape
		var area = Area2D.new()
		area.set_monitoring(true)

		collision_shape.set_debug_color("ee1b946b")
		
		
		area.add_child(collision_shape)
		area.add_to_group("winning_tile")
		
		static_body.add_child(area)
		static_body.name = "StaticBody-WithArea"
		
		#static_body.set_debug_color
	# Use the drawn line's middle as the position of our StaticBody
	var static_body_position = (end_point - start_point) / 2
	# Set the StaticBody's position to the middle of the drawn line
	static_body.set_position(static_body_position)
	
	# add sprite
	var sprite = Sprite2D.new()
	sprite.set_texture(sprite_bmp)
	sprite.set_position(sprite.position + start_point)
	static_body.add_child(sprite)
	
	# Add the StaticBody as a child of the StaticBody
	parent_node.add_child(static_body)
	pass
	#return potentially_null_area


func _on_player_character_player_died(old_value, new_value):
	print("player character died emission %s" % new_value)
	player_is_dead = new_value
	pass # Replace with function body.


func _on_player_character_player_won(old_value, new_value):
	pass # Replace with function body.

func reset_game_state():
	# delete all rigid bodies
	var node_children = node_2d.get_children()
	
	for node_child in node_children:
		var groups = node_child.get_groups()
		if node_child is CharacterBody2D and "player" not in groups:
			node_child.queue_free()
	
	# unkill player
	player_character.unkill()
	
	# place player in initial starting position
	# TODO: fix this since it's not working..
	player_character.position = player_initial_starting_position
	pass

func _on_player_character_ui_manager_restart_button_pressed():
	print("resetting game state")
	reset_game_state()
	#node_2d.restart_
	pass # Replace with function body.
