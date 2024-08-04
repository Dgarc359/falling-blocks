extends Node2D

@onready var node_2d = $"."
@export var width: int = 5
@export var height: int = 5
@export var block_spawn_elapsed_time: int = 3

@onready var time_since_last_spawn = 0

const wallblock_bmp = preload("res://assets/sprites/wall-block-01/wall-block-01.bmp")
const FALLING_BLOCK_01 = preload("res://assets/sprites/falling-block-01/falling-block-01.bmp")

func _draw():
	create_game_map(width, height)
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
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
	rb.set_position(Vector2(32 * randi_range(1, width - 2), -50))
	
	var rect = RectangleShape2D.new()
	rect.set_size(Vector2(32, 32))
	
	var coll = CollisionShape2D.new()
	coll.set_shape(rect)
	rb.add_child(coll)
	
	var sprite = Sprite2D.new()
	sprite.set_texture(FALLING_BLOCK_01)
	rb.add_child(sprite)
	main_node.add_child(rb)
	
	pass


func create_game_map(width: int, height: int):
	print("creating game map")
	for y in range(height):
		for x in range(width):
			if block_should_be_created(x, y, width, height):
				create_static_2d_object(
					node_2d,
					wallblock_bmp,
					Vector2(32 * x,32 * y),
					Vector2(32 * x, 32 * y)
				)
	
	print("finished creating game map")

func block_should_be_created(x: int, y: int, width: int, height: int) -> bool:
	# leave the last row entirely
	# remove only the inner rows
	if y < height - 1 && x != 0 && x != width - 1:
		return false
	
	return true

func create_static_2d_object(
	parent_node: Node2D,
	sprite_bmp,
	start_point: Vector2 = Vector2(0,0), 
	end_point: Vector2 = Vector2(50, 50),
	width: int = 32,
	height: int = 32,
):
	# Create a new Shape
	var shape = RectangleShape2D.new()
	shape.set_size(Vector2(width,height))

	# Create a new collisionShape
	var collision_shape = CollisionShape2D.new()
	
	# Add the shape we created before to this collision shape
	collision_shape.set_shape(shape)
	collision_shape.set_position(collision_shape.position + start_point)

	# Create the StaticBody2D
	var static_body = StaticBody2D.new()
	# Add the CollisionShape we've created as child of the StaticBody
	static_body.add_child(collision_shape)
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

