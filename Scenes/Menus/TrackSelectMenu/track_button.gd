@tool
class_name TrackButton
extends Button

# Export Vars
@export_file("*.tscn") var track: String = "res://Scenes/Tracks" ## The track this button references.
@export var track_name: String: ## The name of the track to be displayed
	set(value):
		track_name = value
		set_visuals()
@export var track_icon: Texture: ## The icon for the track to be displayed
	set(value):
		track_icon = value
		set_visuals()

# Onready Vars
@onready var label: Label = $MarginContainer/VBoxContainer/Label
@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect

func _ready() -> void:
	set_visuals()

## Sets the visual elements of this button.
func set_visuals() -> void:
	if label:
		label.text = track_name
	if texture_rect:
		texture_rect.texture = track_icon
