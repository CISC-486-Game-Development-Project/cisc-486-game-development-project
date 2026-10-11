extends CanvasLayer

# Export Vars
@export_file("*.tscn") var exit_scene: String = "res://Scenes/"
@export var resume_button: Button
@export var options_button: Button
@export var exit_button: Button

# Onready Vars
@onready var options_menu: OptionsMenu = $OptionsMenu

func _ready() -> void:
	# Set up pause screen
	hide()
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	options_menu.hiding.connect(show)
	
	# Focus first button
	resume_button.grab_focus()
	
	# Load scenes
	SceneManager.load_scene(exit_scene)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Pause"):
		if get_tree().paused:
			hide()
			get_tree().paused = false
		else:
			show()
			get_tree().paused = true

## Called when the resume button is pressed.
func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false

## Called when the options button is pressed.
func _on_options_pressed() -> void:
	hide()
	options_menu.show_menu()

## Called when the exit button is pressed.
func _on_exit_pressed() -> void:
	hide()
	get_tree().paused = false
	SceneManager.change_scene(exit_scene, SceneManager.INSTANT)
