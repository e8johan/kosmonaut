extends CanvasLayer

signal finished

func _ready() -> void:
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")

func play() -> void:
	$AnimationPlayer.play("finish")
	
func _on_animation_finished(name: String) -> void:
	emit_signal("finished")