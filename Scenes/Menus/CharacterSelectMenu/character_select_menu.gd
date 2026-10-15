extends Control

# Constants
const SELECT_TWEEN_TIME: float = 0.5 ## The time it takes for the character selection tween to complete.
const FOCUS_TWEEN_TIME: float = 0.1 ## The time it takes for the character focus tween to complete.
const FOCUS_TWEEN_SCALE: float = 1.1 ## The scale used for the character focus tween.
const STATS_TWEEN_TIME: float = 0.1 ## The time it takes for the stats panel tween to complete.

# Export Vars
@export_file("*.tscn") var next_scene: String = "res://Scenes/"
@export_file("*.tscn") var prev_scene: String = "res://Scenes/"
@export var back_button: Button

# Onready Vars
@onready var character_button_container: GridContainer = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/CharacterButtonContainer
@onready var name_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var sub_viewport_grid: GridContainer = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/SubViewportGrid
@onready var stats_panel: PanelContainer = $MarginContainer/HBoxContainer/VBoxContainer/MarginContainer/StatsPanel

# Internal Vars
var character_buttons: Array[Button] ## The character buttons available to select.
var player_count: int = 1 ## The total number of players.
var player_num: int = 1 ## The player currently selecting a character.
var hover_karts: Array[KartModel] = [null, null, null, null] ## The kart models being shown based on hover.
var sub_viewports: Array[SubViewport] ## An array of the subviewports.
var stats_bars: Array[ProgressBar] ## An array of the progress bars used to display stats.
var stats_tween: Tween ## Tween used for showing and hiding the stats_panel.
var select_tweens: Array[Tween] = [null, null, null, null] ## Tweens that play when a character is selected.
var current_focus: Control ## The currently focused control node.

func _ready() -> void:
	# Hide stats panel
	stats_panel.hide()
	
	# Get character_buttons & sub_viewports
	for child in character_button_container.get_children():
		if child is CharacterButton:
			character_buttons.append(child)
	for child in sub_viewport_grid.get_children():
		if child is SubViewportContainer:
			sub_viewports.append(child.get_node("SubViewport"))
	
	# Get stats_bars
	for child in stats_panel.get_node("MarginContainer/VBoxContainer").get_children():
		var bar = child.get_node_or_null("ProgressBar")
		if bar:
			stats_bars.append(bar)
			bar.value = 0.0
	
	# Remove debug karts
	for sub_viewport in sub_viewports:
		for child in sub_viewport.get_children():
			if child is KartModel:
				child.queue_free()
	
	# Set number of characters to be selected & reset selected characters
	player_count = Globals.player_count
	for i in range(player_count):
		if Globals.selected_characters[i]:
			Globals.selected_characters[i] = null
	_setup_viewports()
	
	# Connect button signals
	back_button.pressed.connect(_prev_scene)
	
	for i in len(character_buttons):
		character_buttons[i].pressed.connect(select_character.bind(character_buttons[i]))
		character_buttons[i].focus_entered.connect(hover_character.bind(character_buttons[i]))
		character_buttons[i].mouse_entered.connect(character_buttons[i].grab_focus)
	
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	
	# Focus first button
	character_buttons[0].grab_focus()
	
	# Play sync stream
	AudioManager.change_sync_track(1, 1)

	# Load scenes
	SceneManager.load_scene(next_scene)
	SceneManager.load_scene(prev_scene)

func _process(delta: float) -> void:
	if hover_karts[player_num-1]:
		hover_karts[player_num-1].rotate_y(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Globals.selected_characters[player_count-1]:
			return
		deselect_character()
	elif event.is_action_pressed("Pause"):
		if stats_panel.visible:
			_hide_stats()
		else:
			_show_stats()

## Called when a character is selected.
func select_character(button: CharacterButton) -> void:
	# Set player's selected character
	Globals.selected_characters[player_num-1] = button.character
	
	# Play tween animation & progress character selection process
	if hover_karts[player_num-1]:
		select_tweens[player_num-1] = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		select_tweens[player_num-1].tween_property(hover_karts[player_num-1], "rotation_degrees", Vector3(0,220,0), SELECT_TWEEN_TIME)
		_progress_selection()

## Called when a character is deselected.
func deselect_character() -> void:
	# Set player's selected character
	Globals.selected_characters[player_num-1] = null
	
	# Clean up hovered kart
	for child in sub_viewports[player_num-1].get_children():
		if child is KartModel:
			child.queue_free()
	
	# Regress character selection process
	_regress_selection()

## Called when a character is hovered.
func hover_character(button: CharacterButton) -> void:
	# Clean up previous hovered kart
	for child in sub_viewports[player_num-1].get_children():
		if child is KartModel:
			child.queue_free()
	
	# Add new hovered kart and change text
	var new_char = button.character
	hover_karts[player_num-1] = new_char.stats.kart_model.instantiate()
	hover_karts[player_num-1].position.x += 10 * (player_num-1)
	hover_karts[player_num-1].rotation_degrees.y = 220
	sub_viewports[player_num-1].add_child(hover_karts[player_num-1])
	name_label.text = new_char.char_name + " in the " + new_char.kart_name if new_char.kart_name != "" else new_char.char_name
	
	# Show new hovered kart's stats
	var stats = new_char.stats
	stats_bars[0].value = stats.base_speed
	stats_bars[1].value = stats.base_acceleration
	stats_bars[2].value = stats.base_boost
	stats_bars[3].value = stats.base_handling

## Should be called to show stats_panel.
func _show_stats() -> void:
	# Kill previous tween if still running
	if stats_tween:
		stats_tween.kill()
	
	# Create new tween and run
	stats_tween = create_tween().set_parallel()
	stats_panel.show()
	stats_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	stats_tween.tween_property(stats_panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), STATS_TWEEN_TIME)

## Should be called to hide stats_panel.
func _hide_stats() -> void:
	# Kill previous tween if still running
	if stats_tween:
		stats_tween.kill()
	
	# Create new tween and run
	stats_tween = create_tween().set_parallel()
	stats_tween.tween_property(stats_panel, "modulate", Color(1.0, 1.0, 1.0, 0.0), STATS_TWEEN_TIME)
	stats_tween.tween_callback(stats_panel.hide).set_delay(STATS_TWEEN_TIME)

## Sets up the viewports based on player_count.
func _setup_viewports() -> void:
	# Set grid columns
	if player_count > 2:
		sub_viewport_grid.columns = 2
	else:
		sub_viewport_grid.columns = 1
	
	# Set number of visible viewports
	for i in range(4):
		if i < player_count:
			sub_viewports[i].get_parent().visible = true
		else:
			sub_viewports[i].get_parent().visible = false

## Called after a character is selected. Progresses to next player or next scene if all characters are chosen.
func _progress_selection() -> void:
	# Return if not all players have selected characters
	for i in range(player_count):
		if not Globals.selected_characters[i]:
			player_num += 1
			_reset_focus()
			return
	
	# Progress to next scene when all players have selected characters
	if select_tweens[player_num-1]:
		await select_tweens[player_num-1].finished
	_next_scene()

## Called after a character is deselected. Regresses to previous player or previous scene if all characters are already not chosen.
func _regress_selection() -> void:
	if player_num == 1:
		_prev_scene()
	else:
		player_num -= 1
		_reset_focus()

## Resets the ui focus to the first character_button.
func _reset_focus() -> void:
	if character_buttons[0].has_focus():
		character_buttons[0].release_focus()
	character_buttons[0].grab_focus()

## Called when focused control changes. Uses tweens to accentuate focused control.
func _on_focus_changed(new_focus: Control) -> void:
	# Create new tween
	var tween: Tween = get_tree().create_tween().set_parallel()
	
	# Return old focus to normal
	if current_focus:
		tween.tween_property(current_focus, "scale", Vector2(1,1), FOCUS_TWEEN_TIME)
	
	# Set new focus
	current_focus = new_focus
	
	# Return if new_focus isn't one of the menu buttons
	if not new_focus is CharacterButton or not new_focus in character_buttons:
		return
	
	# Enlarge new focus
	tween.tween_property(current_focus, "scale", Vector2(FOCUS_TWEEN_SCALE, FOCUS_TWEEN_SCALE), FOCUS_TWEEN_TIME)

## Called when all characters are selected.
func _next_scene() -> void:
	SceneManager.change_scene(next_scene, SceneManager.SLIDE_FORWARD)

## Called when going backwards in the menu order.
func _prev_scene() -> void:
	SceneManager.change_scene(prev_scene, SceneManager.SLIDE_BACKWARD)
