# Shop.gd - Shop scene script
extends Control

@onready var coins_label = $CoinsLabel
@onready var shop_container = $ShopContainer
@onready var continue_button = $ContinueButton
@onready var left_glove = $LeftGlove
@onready var right_glove = $RightGlove
@onready var chainmail = $chainmail
@onready var hat = $hat
@onready var boot_left = $bootLeft
@onready var boot_right = $bootRight

# Sample armor data - can be moved to JSON later
var available_armor = [
	{
		"name": "Брониран нагръдник",
		"description": "+0.2x множител на точки",
		"cost": 50,
		"point_multiplier": 0.2
	},
	{
		"name": "Шлем на мъдростта",
		"description": "+5 бонус точки на отговор",
		"cost": 40,
		"flat_bonus": 5
	},
	{
		"name": "Ботуши на скоростта",
		"description": "+3 секунди при отговор от долния ред",
		"cost": 60,
		"bottom_row_time_bonus": 3.0
	},
	{
		"name": "Ръкавици на точността",
		"description": "+0.1x множител на време",
		"cost": 70,
		"time_multiplier": 0.1
	}
]

func _ready():
	activate_armour()
	update_coins_display()
	populate_shop()
	continue_button.pressed.connect(_on_continue_pressed)

func update_coins_display():
	coins_label.text = "Монети: %d" % GameManager.coins

func populate_shop():
	# Clear existing items
	for child in shop_container.get_children():
		child.queue_free()
	
	# Create shop items
	for armor in available_armor:
		var item_panel = create_shop_item(armor)
		shop_container.add_child(item_panel)

func create_shop_item(armor: Dictionary) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(500, 120)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var name_label = Label.new()
	name_label.text = armor.name
	name_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = armor.description
	vbox.add_child(desc_label)
	
	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)
	
	var cost_label = Label.new()
	cost_label.text = "Цена: %d монети" % armor.cost
	hbox.add_child(cost_label)
	
	var buy_button = Button.new()
	buy_button.text = "Купи"
	
	# Check if already owned
	var already_owned = false
	for owned in GameManager.owned_armor:
		if owned.name == armor.name:
			already_owned = true
			break
	
	if already_owned:
		buy_button.text = "Притежавате"
		buy_button.disabled = true
	elif GameManager.coins < armor.cost:
		buy_button.disabled = true
	
	buy_button.pressed.connect(_on_buy_pressed.bind(armor))
	hbox.add_child(buy_button)
	
	return panel

func _on_buy_pressed(armor: Dictionary):
	if GameManager.buy_armor(armor):
		# Auto-equip purchased armor
		GameManager.equip_armor(armor)
		update_coins_display()
		populate_shop() # Refresh shop display
		activate_armour()

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://Scenes/QuizRound.tscn")
func activate_armour():
	if !GameManager.equipped_armor.is_empty():
		for eq in GameManager.equipped_armor:
			if eq.name == "Брониран нагръдник":
				chainmail.visible = true
			elif eq.name == "Шлем на мъдростта":
				hat.visible = true
			elif eq.name == "Ботуши на скоростта":
				boot_left.visible = true
				boot_right.visible = true
			elif eq.name == "Ръкавици на точността":
				left_glove.visible = true
				right_glove.visible = true
