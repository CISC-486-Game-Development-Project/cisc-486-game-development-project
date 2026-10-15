@tool
extends PanelContainer

# Export Vars
@export var refresh_texts: bool: ## Editor button for refreshing hint bar while in the editor.
	set(_value):
		_refresh()

@export var control_hint_label: PackedScene ## The scene used as the label to display control hints.
@export var control_texts: Array[String] ## The number of inputs to display hints for.
@export var control_inputs_keyboard: Array[String] ## The keyboard inputs that map to each control_texts index. Must be the same length as control_texts.
@export var control_inputs_controller: Array[String] ## The controller inputs that map to each control_texts index. Must be the same length as control_texts.

# Onready Vars
@onready var hint_box: HBoxContainer = $MarginContainer/HintBox

# Internal Vars
var hint_labels: Array[Label] ## The array of current hint labels.
var is_controller: bool ## Determines the current input method. False when keyboard, true when controller.

func _ready() -> void:
	# If controllers connected, set is_controller to true, otherwise default is false
	if len(Input.get_connected_joypads()) > 0:
		is_controller = true
	
	# Set up hint_labels
	_refresh_hint_labels()

func _input(event: InputEvent) -> void:
	# If input from joypad detected, set is_controller to true and switch hint texts.
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and event.axis_value > 0.2):
		if not is_controller:
			is_controller = true
			_switch_hints()
	
	# If input from keyboard or mouse detected, set is_controller to false and switch hint texts.
	elif event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		if is_controller:
			is_controller = false
			_switch_hints()

## Updates the text in hint_labels. Should be called whenever is_controller toggles.
func _switch_hints() -> void:
	for i in len(hint_labels):
		hint_labels[i].text = control_inputs_controller[i] + " | " + control_texts[i] if is_controller else control_inputs_keyboard[i] + " | " + control_texts[i]

func _refresh_hint_labels() -> void:
	hint_labels.clear()
	for label in hint_box.get_children():
		label.queue_free()
	for i in len(control_texts):
		var new_label = control_hint_label.instantiate() as Label
		new_label.text = control_inputs_controller[i] + " | " + control_texts[i] if is_controller else control_inputs_keyboard[i] + " | " + control_texts[i]
		hint_box.add_child(new_label)
		hint_labels.append(new_label)

## Called when the refresh_texts button is hit in the editor.
func _refresh() -> void:
	if Engine.is_editor_hint():
		if len(control_texts) != len(control_inputs_keyboard) or len(control_texts) != len(control_inputs_controller):
			push_warning("Incompatable array sizes!")
			return
		_refresh_hint_labels()
		_switch_hints()
