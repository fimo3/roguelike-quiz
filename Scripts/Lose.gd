extends Control

@onready var score_label = $ScoreLabel
@onready var explosion_sprite = $ExplosionSprite

func _ready():
	score_label.text = "Round: %d" % [GameManager.current_round]
	
	if explosion_sprite.sprite_frames:
		explosion_sprite.play("default")
		explosion_sprite.animation_finished.connect(_on_explosion_finished)

func _on_explosion_finished():
	pass

func _on_retry_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
