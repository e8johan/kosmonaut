extends CanvasLayer

signal finished

func play() -> void:
	$AnimationPlayer.play("countdown")
	
func _emit_finished() -> void:
	emit_signal("finished")