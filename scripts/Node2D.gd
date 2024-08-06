extends Node2D

@onready var node_2d = $"."
@onready var player_character = $"PlayerCharacter"

@export var width: int = 5
@export var height: int = 5
@export var block_spawn_elapsed_time: int = 3
@onready var death_ui = $DeathUI
@onready var victory_ui = $VictoryUI

@onready var time_since_last_spawn = 0
const VICTORY_TILE = preload("res://assets/sprites/victory-tile/victory-tile.bmp")
const wallblock_bmp = preload("res://assets/sprites/wall-block-02/wall.png")
const FALLING_BLOCK_01 = preload("res://assets/sprites/spikeball/spikeball.png")

var player_is_dead: bool = false
var padding = 200

func _draw():
	create_game_map(width, height)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
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
	print("spawning falling block")
	var rb = RigidBody2D.new()
	rb.set_position(Vector2(padding + 32 * randi_range(1, width - 2), -50))
	
	var rect = RectangleShape2D.new()
	rect.set_size(Vector2(32, 32))
	
	var coll = CollisionShape2D.new()
	var coll_2 = CollisionShape2D.new()
	var area_2d = Area2D.new()
	
	area_2d.add_child(coll_2)
	#area_2d.set_collision_layer_value(1, true)
	coll.set_shape(rect)
	rb.add_child(area_2d)
	rb.add_child(coll)
	
	var sprite = Sprite2D.new()
	sprite.set_texture(FALLING_BLOCK_01)
	rb.add_child(sprite)
	main_node.add_child(rb)
	
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


#func draw_death_ui():
	#death_ui.z_index = 1000
	#death_ui.show()
	#pass



func _on_player_character_player_died(old_value, new_value):
	print("player character died emission %s" % new_value)
	player_is_dead = new_value
	# queue redraw with you died text
	
	#draw_death_ui()
	
	pass # Replace with function body.


func _on_player_character_player_won(old_value, new_value):
	#if new_value:
		#victory_ui.z_index = 1000
		#victory_ui.show()
	#else:
		#victory_ui.hide()
		#pass
	pass # Replace with function body.
