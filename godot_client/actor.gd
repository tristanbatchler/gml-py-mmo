extends CharacterBody2D

const GRID: int = 32
const SPEED: float = 450.0
const EPS: float = 1.0
const INPUT_QUEUE_MAX_SIZE = 4

var input_queue: Array = []
var next_pos = position
@export var network_client: NetworkClient

@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
	
func enqueue_input(move_dir: Vector2) -> void:
	# We don't want the queue to get too big or it feels unnatural
	if input_queue.size() < INPUT_QUEUE_MAX_SIZE:
		input_queue.append(move_dir)
	else:
		# Remove the oldest input
		input_queue.pop_back()
		

func _input(event):
	var move_dir: Vector2 = Vector2.ZERO
	if event.is_action_pressed("move_right"):
		move_dir = Vector2.RIGHT
	elif event.is_action_pressed("move_left"):
		move_dir = Vector2.LEFT
	elif event.is_action_pressed("move_down"):
		move_dir = Vector2.DOWN
	elif event.is_action_pressed("move_up"):
		move_dir = Vector2.UP
		
	if move_dir != Vector2.ZERO:
		enqueue_input(move_dir)
		
	#network_client.send_packet({
		#"move": {
			#"from_pid": null  # Need to figure out how to pass PID to player
			#"dx": move_dir.x,
			#"dy": move_dir.y
		#}
	#})
	
func get_next_input_direction():
	var next_pos = position
	if input_queue.size() <= 0:
		return null
	
	return input_queue.pop_front()
	
func _physics_process(delta):
	if next_pos == position:
		var next_input_dir = get_next_input_direction()
		if next_input_dir:
			next_pos = position + next_input_dir * GRID
	
	if next_pos != position:
		velocity = (next_pos - position) * SPEED * delta
		
		if position.distance_squared_to(next_pos) < EPS:
			position = next_pos
			velocity = Vector2.ZERO
			
	move_and_slide()

func _process(delta):
	var anim: String = "walk_"
	if velocity == Vector2.ZERO:
		anim = "idle_"
		if not animation_player.current_animation:
			anim += "down"
		else:
			var previous_anim: String = animation_player.current_animation
			anim += previous_anim.split("_")[1]
	
	elif velocity.x > 0:
		anim += "right"
	elif velocity.x < 0:
		anim += "left"
	elif velocity.y > 0:
		anim += "down"
	elif velocity.y < 0:
		anim += "up"
		
		
	animation_player.play(anim)

		
	
	
	
	
	
	
	
