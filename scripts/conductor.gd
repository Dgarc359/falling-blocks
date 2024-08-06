extends AudioStreamPlayer2D

@onready var audio_stream_player_2d = $"."
@export var infinitely_loop_audio: bool = true


func _on_finished():
	if infinitely_loop_audio:
		audio_stream_player_2d.play()
	#pass # Replace with function body.
