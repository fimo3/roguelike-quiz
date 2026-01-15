extends Node

var questions: Array = []
var used_questions: Array = []

func _ready():
	load_questions()

func load_questions():
	var file = FileAccess.open("res://questions.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.get_data()
			if data.has("questions"):
				questions = data.questions
				print("Loaded ", questions.size(), " questions")
		else:
			push_error("Failed to parse questions.json: " + json.get_error_message())
	else:
		push_error("Could not open questions.json")

func get_random_question(turn: int) -> Dictionary:
	if questions.is_empty():
		return {}
	
	var available = []
	for q in questions:
		if q not in used_questions:
			available.append(q)
	
	if available.is_empty():
		used_questions.clear()
		available = questions.duplicate()
	var question = available[randi() % available.size()]
	while question.difficulty != turn:
		question = available[randi() % available.size()]
	used_questions.append(question)
	return question

func get_multiple_questions(count: int) -> Array:
	var result = []
	for i in range(count):
		result.append(get_random_question(1))
	return result
