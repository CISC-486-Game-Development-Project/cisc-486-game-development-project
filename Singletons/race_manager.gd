extends Node

#TODO: Change these back to longer values
const COUNTDOWN_LEAD_IN = 1 ## Delay between start of scene and start of countdown
const COUNTDOWN_SPACING = 1 ## Delay between countdown numbers
const COUNTDOWN_START_VALUE = 3 ## Value the count starts at

signal countdown_update(new_value: int)
signal race_started

@onready var timer = $Timer

# TODO: Consider making this changeable by the player
const TOTAL_KART_COUNT = 4 ## How many karts there will be in the race

var player_count: int = 1 ## How many players there are in the race

# These three are in the same order
# TODO: Make these dynamic
var player_devices: Array[int] = [-1, -1, -1, -1] ## Device ID for controller of each player
var kart_characters: Array[Character] = [null, null, null, null] ## Character resource for all karts in the race, starts with players
var kart_points: Array[int] = [0, 0, 0, 0] ## Points of all karts in race, starts with players

var last_race_positions: Array[int] # Each index represents the place a player of that id came in the last race

var countdown_time: int = 0: ## 0 when a countdown is not running, -1 when leading in, then goes from COUNTDOWN_START_VALUE to 0, where it stays.
	set(new_value):
		countdown_update.emit(new_value)
		countdown_time = new_value

func start_countdown():
	countdown_time = -1 # Indicates lead in specifically
	timer.start(COUNTDOWN_LEAD_IN)

func _on_timer_timeout():
	if countdown_time == -1: # lead in has ended, start the countdown
		countdown_time = COUNTDOWN_START_VALUE
		timer.start(COUNTDOWN_SPACING)
	elif countdown_time > 1:
		countdown_time -= 1
		timer.start(COUNTDOWN_SPACING)
	elif countdown_time == 1: # countdown has finished
		countdown_time = 0
		race_started.emit()
	else:
		push_warning("Countdown is still going at value %s" % countdown_time)

func race_finished(positions: Array[int]):
	last_race_positions = positions
	#TODO: Handle points
