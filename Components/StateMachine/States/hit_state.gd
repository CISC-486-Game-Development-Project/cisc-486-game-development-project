class_name HitState
extends State

# Export Vars
@export var hit_time: float = 1.0

@export_group("Physics Parameters")
@export var fall_velocity: float = -100.0 ## Speed of falling.
@export var fall_gravity: float = 20.0 ## Intensity of gravitational force.

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

# Internal Vars
var hit_timer: SceneTreeTimer

func enter(_prev_state: State) -> void:
	# Start timer for duration of hit state
	hit_timer = get_tree().create_timer(hit_time)
	
	# Begin state's unique animation here
	_play_hit_effect()

func exit(_next_state: State) -> void:
	# Reset hit var
	entity.is_hit = false
	entity.animation_player.stop()

func physics_update(delta: float) -> void:
	# Handle fall movement
	entity.velocity.y = move_toward(entity.velocity.y, fall_velocity, fall_gravity * delta)
	
	check_transitions()

func _play_hit_effect() -> void:
	# Play hit anim (TODO: make the direction of the anim depend on where you got hit)
	match randi_range(0, 1):
			0: entity.animation_player.play("hit_anim_right")
			1: entity.animation_player.play("hit_anim_left")
