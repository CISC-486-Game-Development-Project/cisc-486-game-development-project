extends Node

#TODO: Change these back to longer values
const COUNTDOWN_LEAD_IN = 0.3 ## Delay between start of scene and start of countdown
const COUNTDOWN_SPACING = 0.3 ## Delay between countdown numbers
const COUNTDOWN_START_VALUE = 3 ## Value the count starts at

signal countdown_update(new_value: int)
signal race_started

@onready var timer = $Timer

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
