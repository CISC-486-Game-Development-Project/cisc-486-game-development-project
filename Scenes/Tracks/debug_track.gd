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
var checkpoint_count: int

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
		create_player(0)
	else:
		splitscreen_root.show()
		
		# Get sub_viewports
		sub_viewports = splitscreen_root.sub_viewports
		
		# Add multiple players
		for i in range(Globals.player_count):
			create_player(i, sub_viewports[i])
	
	starting_line.checkpointIndex = 0
	var tempCheckpoint : Checkpoint = starting_line.nextCheckpoint
	var i : int = 1
	while tempCheckpoint != starting_line:
		tempCheckpoint.checkpointIndex = i
		tempCheckpoint = tempCheckpoint.nextCheckpoint
		i += 1
	checkpoint_count = i
	
	RaceManager.start_countdown()

## Creates a player, player_num starts at 0, if parent_array is defined 
func create_player(player_num: int, player_parent=self) -> void:
	var new_player = player_kart.instantiate()
	if Globals.selected_characters[player_num]:
		new_player.kart_stats = Globals.selected_characters[player_num].stats
	new_player.input_handler.player_num = player_num + 1
	player_parent.add_child(new_player)
	new_player.global_position = player_spawn_position
	new_player.global_rotation_degrees.y = player_spawn_rotation
	new_player.race_handler.mostRecentlyPassed = starting_line
	new_player.race_handler.nextMajorCheckpoint = starting_line.nextMajorCheckpoint
	new_player.race_handler.race_laps = race_laps
	new_player.race_handler.finished.connect(kart_finished.bind(new_player))
	karts.append(new_player)
	
func _process(_delta):
	calculate_positions()

## Calculates each kart's position and sets each kart's position variable accordingly
func calculate_positions():
	"""#var ranked_kart_positions = [[[]]]
	#for kart in karts:
		#if kart in finished_karts:
			#continue
		#ranked_kart_positions[kart.race_handler.lap][kart.race_handler.mostRecentlyPassed.checkpointIndex].append(kart)
	var placement = len(finished_karts)
	for i in range(race_laps): #Check if this is number of laps
		for j in range(checkpoint_count):
			if len(ranked_kart_positions[i][j]) > 1:
				#Check how to get this information
				ranked_kart_positions[i][j].sort_custom(func(a, b): a.race_handler.distance < b.race_handler.distance)
			for kart in ranked_kart_positions[i][j]:
				kart.race_handler._set_position = placement  # Is this the correct way of using a setter?
				placement += 1
				"""
	# Finished players have their position locked.
	# Sort unfinished players by laps completed
	# Break ties with their mostRecentlyPassed's checkpoint index
	# Break ties with their distance to the next checkpoint.
	var unfinished_karts: Array[Kart3D]
	for kart in karts:
		if kart not in finished_karts:
			unfinished_karts.append(kart)
	unfinished_karts.sort_custom(_placement_priority)
	var placement = len(finished_karts)
	for kart in unfinished_karts:
		placement += 1
		kart.race_handler.position = placement
			
func _placement_priority(kart_a, kart_b) -> bool:
	if kart_a.race_handler.lap != kart_b.race_handler.lap:
		return kart_a.race_handler.lap > kart_b.race_handler.lap
	if kart_a.race_handler.mostRecentlyPassed.checkpointIndex != kart_b.race_handler.mostRecentlyPassed.checkpointIndex:
		return kart_a.race_handler.mostRecentlyPassed.checkpointIndex > kart_b.race_handler.mostRecentlyPassed.checkpointIndex
	return kart_a.race_handler.distance_to_next_checkpoint < kart_b.race_handler.distance_to_next_checkpoint

func kart_finished(kart):
	finished_karts.append(kart)
