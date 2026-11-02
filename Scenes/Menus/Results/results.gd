extends Control

@export_file var main_menu_scene: String
@onready var main_menu_button = $MainMenuButton

func _ready():
	SceneManager.load_scene(main_menu_scene)
	for i in range(1, RaceManager.TOTAL_KART_COUNT+1):
		var i_index = RaceManager.last_race_positions.find(i)
		$VBoxContainer.get_child(i-1).text = "%s: %s%s" % [RaceManager.kart_characters[i_index].char_name, i, RaceManager.get_position_prefix(i)]
	main_menu_button.grab_focus()

func _on_main_menu_button_pressed():
	SceneManager.change_scene(main_menu_scene)
