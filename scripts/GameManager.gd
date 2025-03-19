extends Node

# Signal to notify when coins change
signal coins_changed

# Variable to store the number of coins
var coins: int = 0

# Function to add coins
func add_coins(amount: int) -> void:
	coins += amount
	emit_signal("coins_changed")  # Emit signal when coins change

# Function to remove coins
func remove_coins(amount: int) -> void:
	coins = max(0, coins - amount)  # Prevent negative coin count
	emit_signal("coins_changed")  # Emit signal when coins change

# Optional: Function to get current coin count (if needed)
func get_coin_count() -> int:
	return coins
