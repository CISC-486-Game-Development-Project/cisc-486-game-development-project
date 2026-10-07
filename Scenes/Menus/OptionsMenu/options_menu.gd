extends CanvasLayer

# Signals
signal showing ## Emitted when showing this menu.
signal hiding ## Emitted when hiding this menu.

# Constants
const TWEEN_TIME: float = 0.5 ## The time it takes for the menu to show or hide.
const OFFSCREEN_POSITION: Vector2 = Vector2(0,1080) ## The position the menu tweens to and from when showing and hiding.

# Onready Vars
@onready var background_panel: Panel = $BackgroundPanel
@onready var options_container: MarginContainer = $OptionsContainer
@onready var temp_back_button: Button = $OptionsContainer/TempBackButton

# Internal Vars
var menu_tween: Tween ## The current tween applying to this menu.

func _ready() -> void:
	temp_back_button.pressed.connect(hide_menu)

## Should be called to show menu.
func show_menu() -> void:
	# Kill previous tween if still running
	if menu_tween:
		menu_tween.kill()
	
	# Create new tween and run
	menu_tween = get_tree().create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	visible = true
	options_container.set_position(OFFSCREEN_POSITION)
	menu_tween.tween_property(options_container, "position", Vector2.ZERO, TWEEN_TIME)
	menu_tween.tween_property(background_panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), TWEEN_TIME)
	
	# Emit signal & grab focus
	showing.emit()
	temp_back_button.grab_focus()

## Should be called to hide menu.
func hide_menu() -> void:
	# Kill previous tween if still running
	if menu_tween:
		menu_tween.kill()
	
	# Create new tween and run
	menu_tween = get_tree().create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	options_container.set_position(Vector2.ZERO)
	menu_tween.tween_property(options_container, "position", OFFSCREEN_POSITION, TWEEN_TIME)
	menu_tween.tween_property(background_panel, "modulate", Color(1.0, 1.0, 1.0, 0.0), TWEEN_TIME)
	menu_tween.tween_callback(func(): visible = false).set_delay(TWEEN_TIME)
	
	# Emit signal
	hiding.emit()
