class_name OptionsMenu
extends CanvasLayer

# Signals
signal showing ## Emitted when showing this menu.
signal hiding ## Emitted when hiding this menu.

# Constants
const TWEEN_TIME: float = 0.5 ## The time it takes for the menu to show or hide.
const OFFSCREEN_POSITION: Vector2 = Vector2(0, 1080) ## The position the menu tweens to and from when showing and hiding.

# Exprot Vars
@export var master_volume_slider: HSlider
@export var music_volume_slider: HSlider
@export var sfx_volume_slider: HSlider
@export var voice_volume_slider: HSlider

# Onready Vars
@onready var background_panel: Panel = $BackgroundPanel
@onready var options_container: MarginContainer = $OptionsContainer
@onready var back_button: Button = $OptionsContainer/BackButton

# Internal Vars
var menu_tween: Tween ## The current tween applying to this menu.

func _ready() -> void:
	_set_up_options()
	hide()
	back_button.pressed.connect(hide_menu)

######################
## Showing & Hiding ##
######################

## Should be called to show menu.
func show_menu() -> void:
	# Kill previous tween if still running
	if menu_tween:
		menu_tween.kill()
	
	# Create new tween and run
	menu_tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	visible = true
	options_container.set_position(OFFSCREEN_POSITION)
	background_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	menu_tween.tween_property(options_container, "position", Vector2.ZERO, TWEEN_TIME)
	menu_tween.tween_property(background_panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), TWEEN_TIME)
	
	# Emit signal & grab focus
	showing.emit()
	back_button.grab_focus()

## Should be called to hide menu.
func hide_menu() -> void:
	# Kill previous tween if still running
	if menu_tween:
		menu_tween.kill()
	
	# Create new tween and run
	menu_tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	options_container.set_position(Vector2.ZERO)
	menu_tween.tween_property(options_container, "position", OFFSCREEN_POSITION, TWEEN_TIME)
	menu_tween.tween_property(background_panel, "modulate", Color(1.0, 1.0, 1.0, 0.0), TWEEN_TIME)
	menu_tween.tween_callback(func(): visible = false).set_delay(TWEEN_TIME)
	
	# Emit signal
	hiding.emit()

#####################
## Setup Functions ##
#####################

## Called on ready to set up the default values for the options and connect to the proper UI signals.
func _set_up_options() -> void:
	# Volume Sliders
	master_volume_slider.value = AudioManager.master_volume
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	
	music_volume_slider.value = AudioManager.music_volume
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	
	sfx_volume_slider.value = AudioManager.sfx_volume
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	
	voice_volume_slider.value = AudioManager.voice_volume
	voice_volume_slider.value_changed.connect(_on_voice_volume_changed)

#############################
## Change Signal Functions ##
#############################

## Called when the Master Volume slider emits value_changed signal.
func _on_master_volume_changed(value: float) -> void:
	AudioManager.set_master_volume(value)

## Called when the Music Volume slider emits value_changed signal.
func _on_music_volume_changed(value: float) -> void:
	AudioManager.set_music_volume(value)

## Called when the SFX Volume slider emits value_changed signal.
func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value)

## Called when the Voices Volume slider emits value_changed signal.
func _on_voice_volume_changed(value: float) -> void:
	AudioManager.set_voice_volume(value)
