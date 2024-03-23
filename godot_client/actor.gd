extends CharacterBody2D

const GRID: int = 32
const SPEED: float = 450.0
const EPS: float = 1.0

var next_pos: Vector2 = Vector2.ZERO

func _ready():
	next_pos = position

func _input(event):
	if next_pos != position:
		return	# Don't accept movement input until we are aligned
	if event.is_action_pressed("move_right"):
		next_pos.x += GRID
	elif event.is_action_pressed("move_left"):
		next_pos.x -= GRID
	elif event.is_action_pressed("move_down"):
		next_pos.y += GRID
	elif event.is_action_pressed("move_up"):
		next_pos.y -= GRID
	
func _physics_process(delta):
	if next_pos != position:
		velocity = (next_pos - position) * SPEED * delta
		
		if position.distance_squared_to(next_pos) < EPS:
			position = next_pos
			
	move_and_slide()

func _process(delta):
	print_debug("Position: %s\tNext: %s" % [position, next_pos])
	
	
	
	
	
	
	
	
