extends KinematicBody

signal crash

export var move_speed : float = 6.0
export var velocity : float = 6.0
export var jump_force : float = 3.0
export var max_fall_speed : float = 100.0
export var gravity : float = 10.0
export var bounciness : float = 0.5
export var min_bounce : float = 1.0

var running : bool = false

var y_velocity : float = 0.0
var has_bounced : bool = false # No bounce sound on initial landing - only when player has bounced
var has_fallen : bool = false  # Only play the fall sound once

func start():
	running = true
	set_physics_process(true)
	
func stop():
	running = false
	set_physics_process(false)

func _ready() -> void:
	$BouncePingPlayer.stream.loop = false
	$BounceBoingPlayer.stream.loop = false
	$FallOowPlayer.stream.loop = false
	$CrashBoomPlayer.stream.loop = false
	
	running = false
	set_physics_process(false)

func _physics_process(delta : float) -> void:
	# Calculate movement from keys
	var move_dir : float = 0.0
	if Input.is_action_pressed("left"):
		move_dir = -move_speed
	if Input.is_action_pressed("right"):
		move_dir = move_speed
	
	# Move
	var v := Vector3(velocity, y_velocity, move_dir)
	var v_actual := move_and_slide(v, Vector3(0, 1, 0))
		
	# Calculate fall for next frame
	y_velocity -= gravity * delta
	if y_velocity < -max_fall_speed:
		y_velocity = -max_fall_speed
	
	if is_on_floor():
		# Bounce
		if v.y < -0.11 and v.y < v_actual.y:
			y_velocity = -v.y * bounciness
			if y_velocity < min_bounce:
				y_velocity = -0.1
				if has_bounced:
					$BouncePingPlayer.play()
			else:
				if has_bounced:
					$BouncePingPlayer.play()
		else:
			y_velocity = -0.1
		
		if Input.is_action_just_pressed("jump"):
			y_velocity = jump_force
			has_bounced = true
			$BounceBoingPlayer.play()
	else:
		if to_global(Vector3.ZERO).y < 0.0 and not has_fallen:
			$FallOowPlayer.play()
			has_fallen = true
	
	if is_on_wall():
		# We are only interested in hitting a wall head-on - you may slide along a wall
		var is_deadly := false
		for i in range(0,get_slide_count()):
			var c := get_slide_collision(i)
			if c.normal.x < -0.1:
				is_deadly = true
		
		if is_deadly:
			$CrashBoomPlayer.play()
			emit_signal("crash")

func reset_to(pos : Vector3) -> void:
	y_velocity = -0.1
	self.translation = pos
	has_bounced = false
	has_fallen = false
	set_physics_process(false)
