extends Control

@onready var question_label = $QuestionLabel
@onready var answer_container = $AnswerContainer
@onready var score_label = $ScoreLabel
@onready var timer_label = $TimerLabel
@onready var threshold_label = $ThresholdLabel
@onready var coin_label = $CoinLabel

var current_question: Dictionary = {}
var round_time: float = 120.0
var base_round_time: float = 120.0

func _ready():
	GameManager.reset_round_modifiers()
	round_time = base_round_time * GameManager.time_multiplier
	update_ui()
	load_next_question()

func _process(delta):
	if round_time <= 0:
		round_time = 0;
		end_round()
		question_label.queue_free()
		answer_container.queue_free()
	else:
		round_time -= delta
	timer_label.text = "Time: %.1f" % round_time
	_on_score_change()

func load_next_question():
	current_question = QuestionsDatabase.get_random_question(GameManager.current_round - 1)
	
	if current_question.is_empty():
		push_error("No questions available!")
		return
	
	question_label.text = current_question.text
	
	for child in answer_container.get_children():
		child.queue_free()
	
	var answers = current_question.answers
	for i in range(answers.size()):
		var button = Button.new()
		button.text = answers[i]
		button.custom_minimum_size = Vector2(400, 60)
		button.pressed.connect(_on_answer_selected.bind(i))
		answer_container.add_child(button)

func _on_answer_selected(answer_index: int):
	var correct_index = current_question.correct
	var is_correct = answer_index == correct_index
	
	if is_correct:
		var points = 10
		
		var button_count = answer_container.get_child_count()
		if answer_index == button_count - 1:
			for armor in GameManager.equipped_armor:
				if armor.has("bottom_row_time_bonus"):
					round_time += armor.bottom_row_time_bonus
		
		var final_points = GameManager.add_score(points)

		show_feedback("Правилно! +%d pts" % final_points, Color.GREEN)
	else:
		var final_points = GameManager.decrease_score(-5)
		
		show_feedback("Грешно! %d pts" % final_points, Color.RED)
	
	update_ui()
	await get_tree().create_timer(0.5).timeout
	
	if GameManager.current_score >= GameManager.score_threshold or round_time <= 0:
		end_round()
	else:
		load_next_question()

func show_feedback(text: String, color: Color):
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.position = Vector2(500, 300)
	add_child(label)
	
	await get_tree().create_timer(0.5).timeout
	label.queue_free()

func update_ui():
	score_label.text = "Score: %d / %d" % [GameManager.current_score, GameManager.score_threshold]
	threshold_label.text = "Round: %d | Target: %d" % [GameManager.current_round, GameManager.score_threshold]

func end_round():
	var success = GameManager.complete_round()
	
	if success:
		get_tree().change_scene_to_file("res://Scenes/Shop.tscn")
	else:
		var label = Label.new()
		label.text = "Неуспешно! Score: %d/%d" % [GameManager.current_score, GameManager.score_threshold]
		label.position = Vector2(400, 300)
		add_child(label)
		
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://Scenes/Main.tscn")
		
func _on_score_change():
	var coins = GameManager.calculate_coins_earned()
	coin_label.text = "Coins: $%d" % [coins];
