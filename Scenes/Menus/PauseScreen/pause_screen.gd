extends CanvasLayer

@export var options_scene: PackedScene
@export var exit_scene: PackedScene
@export var resume_button: Button
@export var options_button: Button
@export var exit_button: Button

func _ready() -> void:
	# Set up pause screen
	visible = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Focus first button
	resume_button.grab_focus()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Pause"):
		if get_tree().paused:
			visible = false
			get_tree().paused = false
		else:
			visible = true
			get_tree().paused = true

## Called when the resume button is pressed.
func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false

## Called when the options button is pressed.
func _on_options_pressed() -> void:
	visible = false
	get_tree().paused = false
	SceneManager.load_scene(options_scene)

## Called when the exit button is pressed.
func _on_exit_pressed() -> void:
	visible = false
	get_tree().paused = false
	SceneManager.load_scene(exit_scene)
