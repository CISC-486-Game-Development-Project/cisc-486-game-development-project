extends Control

@export var play_scene: StringName = &""
@export var title_music: AudioStream

func _ready() -> void:
	# Play title music
	AudioManager.change_bgm(title_music)

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		_on_pressed()

## Called when any button is pressed.
func _on_pressed() -> void:
	SceneManager.load_scene(play_scene)
