extends Node3D

@export var track_music: AudioStream ## Music to play while on this track.
@export var player_kart: PackedScene

func _ready() -> void:
	# Begin music
	AudioManager.change_bgm(track_music)
	
	# Add players to scene
	for i in range(Globals.player_count):
		var new_player = player_kart.instantiate()
		if Globals.selected_characters[i]:
			new_player.kart_stats = Globals.selected_characters[i].stats
		new_player.global_position = Vector3(5,1,30)
		new_player.rotate_y(PI/2)
		add_child(new_player)
