extends CanvasLayer

@export_file var main_menu_scene: String
@export var label_container: Container

func _ready():
	hide_rankings()
	SceneManager.load_scene(main_menu_scene)

func show_rankings():
	for i in range(1, RaceManager.TOTAL_KART_COUNT+1):
		var i_index = RaceManager.last_race_positions.find(i)
		var current_label := label_container.get_child(i-1) as KartResultLabel
		current_label.placement_label.text = "%s%s" % [i, RaceManager.get_position_prefix(i)]
		current_label.kart_label.text = "%s" % RaceManager.kart_characters[i_index].char_name
	show()

func hide_rankings():
	hide()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("Forward"):
		_on_return_pressed()

func _on_return_pressed():
	SceneManager.change_scene(main_menu_scene)
