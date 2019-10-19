extends Spatial

onready var player := $Player
onready var goal_pos := $GoalPosition
onready var start_pos := $StartPosition

func _ready():
	player.connect("crash", self, "_on_player_crashed")
	_reset_player()
	
	yield(get_tree().create_timer(3), "timeout")	
	player.start()
	
func _reset_player() -> void:
	player.reset_to(start_pos.to_global(Vector3.ZERO))
	yield(get_tree().create_timer(1), "timeout")	
	player.start()

func _on_player_crashed() -> void:
	print("CRASHED")
	_reset_player()
	yield(get_tree().create_timer(1), "timeout")	
	player.start()

func _process(delta) -> void:
	var player_pos : Vector3 = player.to_global(Vector3.ZERO)
	
	if player_pos.y < -2.0:
		print("FELL")
		_reset_player()
		yield(get_tree().create_timer(1), "timeout")	
		player.start()
		return
		
	if player_pos.x > goal_pos.to_global(Vector3.ZERO).x and player.running:
		print("GOAL")
		player.stop()
		yield(get_tree().create_timer(5), "timeout")	
		get_tree().quit()