extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

## Called when the progress of loading the next scene changes.
func _on_progress_changed(_new_value: float) -> void:
	pass # Implement something on load screen to show progress here

## Called when loading of the next scene finishes.
func _on_load_finished() -> void:
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	queue_free()

func wait_until_ready():
	if animation_player.is_playing():
		await animation_player.animation_finished
