extends Control

@export_file var main_menu_scene: String

func _ready():
	SceneManager.load_scene(main_menu_scene)
	for i in range(RaceManager.TOTAL_KART_COUNT):
		var i_index = RaceManager.last_race_positions.find(i)
		$VBoxContainer.get_child(i).text = "%s: %sst" % [RaceManager.kart_characters[i_index].char_name, i+1]


func _on_main_menu_button_pressed():
	SceneManager.change_scene(main_menu_scene)
