extends CharacterBody2D

const GRID: int = 32
const SPEED: float = 450.0
const EPS: float = 1.0
const INPUT_QUEUE_MAX_SIZE = 4

var input_queue: Array = []


signal network_move(pid: String, dx: int, dy: int)

@onready var animation_player := $Sprite2D/AnimationPlayer
@onready var nameplate := $Nameplate
@onready var chat_label := $ChatLabel
@onready var chat_timer := $ChatLabel/Timer
@onready var sprite := $Sprite2D

var is_player
var actor_name: String
var next_pos: Vector2
var image_index: int

func _ready():
	nameplate.text = actor_name
	chat_timer.connect("timeout", _on_chat_timer_timeout)
	
	var tex: Texture2D
	match image_index:
		0:
			tex = preload("res://spritesheets/monk.png")
		1:
			tex = preload("res://spritesheets/rat.png")
		2: 
			tex = preload("res://spritesheets/oldwoman.png")
		3: 
			tex = preload("res://spritesheets/draconian.png")
		_:
			tex = preload("res://spritesheets/default.png")
			
	sprite.texture = tex
	

func init(_position: Vector2, _name: String, _image_index: int, _is_player: bool):
	next_pos = _position
	position = next_pos
	actor_name = _name
	image_index = _image_index
	is_player = _is_player
	return self
	
func enqueue_input(move_dir: Vector2) -> void:
	# We don't want the queue to get too big or it feels unnatural
	if input_queue.size() < INPUT_QUEUE_MAX_SIZE:
		input_queue.append(move_dir)
	else:
		# Remove the oldest input
		input_queue.pop_back()
		

func _input(event):
	if not is_player:
		return
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
	
func get_next_input_direction():
	if input_queue.size() <= 0:
		return null
	
	return input_queue.pop_front()
	
func _physics_process(delta):
	if next_pos == position:
		var next_input_dir = get_next_input_direction()
		if next_input_dir:
			var delta_pos = next_input_dir * GRID
			next_pos = position + delta_pos
			
			if is_player:
				NetworkClient.send_packet({
					"move": {
						"from_pid": StateManager.pid,
						"dx": delta_pos.x,
						"dy": delta_pos.y
					}
				})
	
	if next_pos != position:
		velocity = (next_pos - position) * SPEED * delta
		
		if position.distance_squared_to(next_pos) < EPS:
			position = next_pos
			velocity = Vector2.ZERO

	move_and_slide()
	
func say(message: String):
	chat_label.text = message
	chat_timer.start()
	
func _on_chat_timer_timeout():
	chat_label.text = ""
	

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

	
	
	
	
	
	
