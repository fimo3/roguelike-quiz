extends Node2D

@onready var quizRound = $".."

func _physics_process(delta: float) -> void:
	var time_ratio = quizRound.round_time / quizRound.base_round_time
	rotation_degrees = time_ratio * 360.0
