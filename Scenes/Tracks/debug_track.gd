extends Node3D

@export var track_music: AudioStream ## Music to play while on this track.
@export var player_kart: PackedScene

@onready var splitscreen_root: Control = $HUD/SplitscreenRoot

var sub_viewports: Array[SubViewport]

func _ready() -> void:
	# Begin music
	AudioManager.change_bgm(track_music)
	
	# Add players to scene
	if Globals.player_count == 1:
		splitscreen_root.hide()
		
		# Add one player
		var new_player = player_kart.instantiate()
		if Globals.selected_characters[0]:
			new_player.kart_stats = Globals.selected_characters[0].stats
		new_player.input_handler.player_num = 1
		add_child(new_player)
		new_player.global_position = Vector3(5,1,30)
	else:
		splitscreen_root.show()
		
		# Get sub_viewports
		sub_viewports = splitscreen_root.sub_viewports
		
		# Add multiple players
		for i in range(Globals.player_count):
			var new_player = player_kart.instantiate()
			if Globals.selected_characters[i]:
				new_player.kart_stats = Globals.selected_characters[i].stats
			new_player.input_handler.player_num = i+1
			sub_viewports[i].add_child(new_player)
			new_player.global_position = Vector3(5*i,1,30)
