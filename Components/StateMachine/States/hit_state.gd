class_name HitState
extends State

# Export Vars
@export var hit_time: float = 1.0

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

# Internal Vars
var hit_timer: SceneTreeTimer

func enter(_prev_state: State) -> void:
	# Reduce velocity
	entity.velocity *= 0.2
	
	# Start timer for duration of hit state
	hit_timer = get_tree().create_timer(hit_time)
	
	# Begin state's unique animation here
	_play_hit_effect()

func physics_update(_delta: float) -> void:
	check_transitions()

func _play_hit_effect() -> void:
	# Play hit anim
	entity.animation_player.play("hit_anim_1")
