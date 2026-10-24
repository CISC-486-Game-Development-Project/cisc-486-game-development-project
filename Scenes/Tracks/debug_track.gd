## This script is entirely placeholder code for before a proper track/race system is implemented.
## Everything is subject to change and not indicative of any final product.
extends Node3D

@export var track_music: AudioStream ## Music to play while on this track.
@export var player_kart: PackedScene
@export var pause_screen_scene: PackedScene
@export var hud_scene: PackedScene
@export var player_spawn_position: Vector3
@export var player_spawn_rotation: float
@export var starting_line: Checkpoint
@export var race_laps: int = 1

var pause_screen: CanvasLayer
var hud: CanvasLayer
var splitscreen_root: Control

var sub_viewports: Array[SubViewport]

var karts: Array[Kart3D]
var finished_karts: Array[Kart3D]

func _ready() -> void:
	# Begin music
	AudioManager.change_bgm.call_deferred(track_music)
	
	# Add UI to scene
	pause_screen = pause_screen_scene.instantiate()
	add_child(pause_screen)
	hud = hud_scene.instantiate()
	add_child(hud)
	splitscreen_root = hud.get_node("SplitscreenRoot")
	
	# Add players to scene
	if Globals.player_count == 1:
		splitscreen_root.hide()
		
		# Add one player
		var new_player = player_kart.instantiate()
		if Globals.selected_characters[0]:
			new_player.kart_stats = Globals.selected_characters[0].stats
		new_player.input_handler.player_num = 1
		add_child(new_player)
		new_player.global_position = player_spawn_position
		new_player.global_rotation_degrees.y = player_spawn_rotation
		new_player.race_handler.mostRecentlyPassed = starting_line
		new_player.race_handler.nextMajorCheckpoint = starting_line.nextMajorCheckpoint
		karts.append(new_player)
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
			new_player.race_handler.mostRecentlyPassed = starting_line
			new_player.race_handler.nextMajorCheckpoint = starting_line.nextMajorCheckpoint
			sub_viewports[i].add_child(new_player)
			new_player.global_position = player_spawn_position * Vector3(i,1,1)
			new_player.global_rotation_degrees.y = player_spawn_rotation
			karts.append(new_player)
	starting_line.body_entered.connect(lap_check)
	starting_line.body_entered.disconnect(starting_line._on_body_entered)
	
	starting_line.checkpointIndex = 0
	var tempCheckpoint : Checkpoint = starting_line.nextCheckpoint
	var i : int = 1
	while tempCheckpoint != starting_line:
		tempCheckpoint.checkpointIndex = i
		tempCheckpoint = tempCheckpoint.nextCheckpoint
		i += 1
	
func _process(_delta):
	calculate_positions()

## Calculates each kart's position and sets each kart's position variable accordingly
func calculate_positions():
	# Finished players have their position locked.
	# Sort unfinished players by laps completed
	# Break ties with their mostRecentlyPassed's checkpoint index
	# Break ties with their distance to the next checkpoint.
	pass

func lap_check(body):
	if not body is Kart3D:
		return
	var kart = body as Kart3D
	var valid_lap = kart.race_handler.entered_checkpoint(starting_line)
	if valid_lap:
		if kart.race_handler.lap >= race_laps:
			# kart has finished the race
			finished_karts.append(kart)
			# TODO: indicate this has happenned
		else:
			kart.race_handler.lap += 1
