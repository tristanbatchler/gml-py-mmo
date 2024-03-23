extends CharacterBody2D

const GRID: int = 32
const SPEED: float = 450.0
const EPS: float = 1.0

var next_pos: Vector2 = Vector2.ZERO
@export var network_client: NetworkClient

func _ready():
	next_pos = position

func _input(event):
	if next_pos != position:
		return	# Don't accept movement input until we are aligned
		
	var move_dir: Vector2 = Vector2.ZERO
	if event.is_action_pressed("move_right"):
		move_dir.x = GRID
	elif event.is_action_pressed("move_left"):
		move_dir.x = -GRID
	elif event.is_action_pressed("move_down"):
		move_dir.y = GRID
	elif event.is_action_pressed("move_up"):
		move_dir.y = -GRID
		
	if move_dir == Vector2.ZERO:
		return
		
	next_pos += move_dir
		
	#network_client.send_packet({
		#"move": {
			#"from_pid": null  # Need to figure out how to pass PID to player
			#"dx": move_dir.x,
			#"dy": move_dir.y
		#}
	#})
	
func _physics_process(delta):
	if next_pos != position:
		velocity = (next_pos - position) * SPEED * delta
		
		if position.distance_squared_to(next_pos) < EPS:
			position = next_pos
			
	move_and_slide()

func _process(delta):
	print_debug("Position: %s\tNext: %s" % [position, next_pos])
	
	
	
	
	
	
	
	
