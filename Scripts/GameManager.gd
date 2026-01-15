extends Node

var coins: int = 10
var current_round: int = 1
var score_threshold: int = 100
var owned_armor: Array = []
var equipped_armor: Array = []

var current_score: int = 0
var time_multiplier: float = 1.0
var point_multiplier: float = 1.0
var flat_bonus: int = 0

signal coins_changed(new_amount)
signal round_completed(coins_earned)
signal round_failed

func _ready():
	reset_round_modifiers()

func reset_round_modifiers():
	time_multiplier = 1.0
	point_multiplier = 1.0
	flat_bonus = 0
	current_score = 200
	
	for armor in equipped_armor:
		apply_armor_effects(armor)

func apply_armor_effects(armor: Dictionary):
	if armor.has("point_multiplier"):
		point_multiplier += armor.point_multiplier
	if armor.has("flat_bonus"):
		flat_bonus += armor.flat_bonus
	if armor.has("time_multiplier"):
		time_multiplier += armor.time_multiplier

func add_score(points: int):
	var final_points = int((points + flat_bonus) * point_multiplier)
	current_score += final_points
	return final_points

func decrease_score(points: int):
	#var final_points = int((points + flat_bonus) * point_multiplier)
	if current_score <= 0:
		points = 0
	current_score += points
	return points


func complete_round():
	if current_score >= score_threshold:
		var coins_earned = calculate_coins_earned()
		coins += coins_earned
		emit_signal("coins_changed", coins)
		emit_signal("round_completed", coins_earned)
		
		current_round += 1
		score_threshold = int(score_threshold * 1.3)
		return true
	else:
		emit_signal("round_failed")
		return false

func calculate_coins_earned() -> int:
	var base_coins = 0
	var bonus = int((current_score) / 10.0)
	return base_coins + bonus

func buy_armor(armor: Dictionary) -> bool:
	if coins >= armor.cost:
		coins -= armor.cost
		owned_armor.append(armor)
		emit_signal("coins_changed", coins)
		return true
	return false

func equip_armor(armor: Dictionary):
	if armor in owned_armor and armor not in equipped_armor:
		equipped_armor.append(armor)

func unequip_armor(armor: Dictionary):
	equipped_armor.erase(armor)
