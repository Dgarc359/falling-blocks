extends Node2D
@onready var character_body_2d = $CharacterBody2D



signal player_died(old_value: bool, new_value: bool)
signal player_won(old_value: bool, new_value: bool)

signal ui_manager_restart_button_pressed()

func unkill():
	character_body_2d.unkill()

func _on_ui_manager_restart_button_pressed():
	ui_manager_restart_button_pressed.emit()
	pass # Replace with function body.
