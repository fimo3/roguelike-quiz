extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var title_label = $VBoxContainer/TitleLabel

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	
	GameManager.coins = 0
	GameManager.current_round = 1
	GameManager.score_threshold = 100
	GameManager.owned_armor = []
	GameManager.equipped_armor = []
	
	get_tree().change_scene_to_file("res://Scenes/QuizRound.tscn")

func _on_quit_pressed():
	get_tree().quit()
