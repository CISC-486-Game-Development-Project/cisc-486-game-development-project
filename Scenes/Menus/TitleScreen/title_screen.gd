extends Control

@export_file("*.tscn") var play_scene: String = "res://Scenes/"
@export var title_music: AudioStream

func _ready() -> void:
	# Play title music
	AudioManager.change_bgm(title_music)
	
	# Load scenes
	SceneManager.load_scene(play_scene)

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		_on_pressed()

## Called when any button is pressed.
func _on_pressed() -> void:
	SceneManager.change_scene(play_scene, SceneManager.SLIDE_FORWARD)
