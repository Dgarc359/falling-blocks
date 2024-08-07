extends Control

signal restart_button_pressed()



@onready var death_ui = $DeathUI
@onready var victory_ui = $VictoryUI

func enable_death_ui(enable: bool):
	if enable:
		death_ui.show()
	else:
		death_ui.hide()

func enable_victory_ui(enable:bool):
	if enable:
		victory_ui.show()
	else:
		victory_ui.hide()


func _on_death_ui_restart_button_pressed():
	restart_button_pressed.emit()
	pass # Replace with function body.
