extends Node

# Signals
signal coins_changed
signal level_cleared(level_number)
signal level_progress_updated

# Save configuration
const SAVE_PATH = "user://game_save.dat"
var coins: int = 0

# Level data configuration
var level_data = {
	"unlocked_levels": 1,
	"cleared_levels": []
}

# Initialize and load saved data
func _ready():
	load_game()

# Coin functions
func add_coins(amount: int) -> void:
	coins += amount
	save_game()  # Save game state after changing coins
	emit_signal("coins_changed")

func remove_coins(amount: int) -> void:
	coins = max(0, coins - amount)
	save_game()  # Save game state after changing coins
	emit_signal("coins_changed")

func get_coin_count() -> int:
	return coins

# Level completion functions
func clear_level(level_number: int):
	if !level_data.cleared_levels.has(level_number):
		level_data.cleared_levels.append(level_number)
		print("Level %d cleared!" % level_number)  # Debugging output
	
	if level_number >= level_data.unlocked_levels:
		level_data.unlocked_levels = level_number + 1
		print("Level %d unlocked!" % (level_number + 1))  # Debugging output
	
	save_game()
	emit_signal("level_cleared", level_number)  # Emit signal when a level is cleared

# Save/load functionality for both coins and levels
func save_game():
	var save_data = {
		"coins": coins,
		"level_data": level_data
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(save_data)
	file.close()
	print("Game saved!")  # Debugging output

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var save_data = file.get_var()
		coins = save_data.get("coins", 0)
		level_data = save_data.get("level_data", {
			"unlocked_levels": 1,
			"cleared_levels": []
		})
		file.close()
		print("Game loaded!")  # Debugging output
		print("Coins: %d" % coins)  # Debugging output
		print("Unlocked Levels: %d" % level_data.unlocked_levels)  # Debugging output
	else:
		coins = 0  # Initial state for new players
		level_data = {
			"unlocked_levels": 1,
			"cleared_levels": []
		}
	
	emit_signal("coins_changed")
