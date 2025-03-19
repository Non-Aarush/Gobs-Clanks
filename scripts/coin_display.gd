# CoinDisplay.gd
extends CanvasLayer

@onready var coin_label: Label = $Control/CoinLabel  # Assuming your label is named CoinLabel
@onready var coin_icon: TextureRect = $Control/CoinIcon  # Assuming your TextureRect is named CoinIcon

var last_coin_count: int = -1  # Initialize with an invalid value

func _ready():
	update_coin_display()  # Initialize display with current coins

func _process(delta):
	# Check if the coin count has changed
	if GameManager.coins != last_coin_count:
		last_coin_count = GameManager.coins  # Update last known coin count
		update_coin_display()  # Update display when coins change

func update_coin_display():
	coin_label.text = ": %d" % GameManager.coins  # Update label with current coin count
