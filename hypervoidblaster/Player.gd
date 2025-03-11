extends CharacterBody2D

@export var speed: float = 550.0  
@export var acceleration: float = 7000.0  
@export var friction: float = 6000.0  
@export var base_gravity: float = 2000.0  
@export var max_gravity: float = 3250.0  
@export var gravity_increase_rate: float = 3000.0  
@export var jump_force: float = 900.0  
@export var dash_speed: float = 1200.0  
@export var dash_time: float = 0.12  
@export var dash_cooldown: float = 1.5  
@export var coyote_time: float = 0.15  # Grace period after leaving a platform
@export var jump_buffer_time: float = 0.2  # Time before landing to register a jump

@export var fire_rate: float = 0.2  # Time between shots

var direction: float = 1  
var current_gravity: float = base_gravity  
var is_dashing: bool = false
var dash_timer: float = 0
var can_dash: bool = true  
var dash_cooldown_timer: float = 0

var coyote_timer: float = 0
var jump_buffer_timer: float = 0

@onready var sprite = $PlayerSprite
@onready var gun = $Gun  # Reference the gun scene inside the player
@onready var cursor_sprite = %Cursor  # Cursor sprite inside player
@onready var animation_player = $AnimationPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # Hide default cursor

func _process(delta):
	# Move the cursor to follow the mouse position
	cursor_sprite.global_position = get_global_mouse_position()

	# Jump buffering: Store jump input
	if Input.is_action_just_pressed("ui_up"):
		jump_buffer_timer = jump_buffer_time

func _physics_process(delta):
	# Handle gravity scaling
	if not is_dashing:
		if velocity.y < 0:
			current_gravity = base_gravity
		else:
			current_gravity = min(current_gravity + gravity_increase_rate * delta, max_gravity)

		velocity.y += current_gravity * delta  
	
	# Handle movement
	var input_direction = Input.get_axis("ui_left", "ui_right")  
	if input_direction != 0:
		velocity.x = move_toward(velocity.x, input_direction * speed, acceleration * delta)
		direction = input_direction  
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	if Input.get_axis("ui_left", "ui_right") == 0:
		animation_player.play("Idle")  
	elif Input.get_axis("ui_left", "ui_right") != 0:
		animation_player.play("Run")

	# Coyote time: Track how long since last on floor
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Jump handling with coyote time & jump buffering
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta  # Reduce timer

	if coyote_timer > 0 and jump_buffer_timer > 0:
		velocity.y = -jump_force
		current_gravity = base_gravity  
		jump_buffer_timer = 0  # Reset buffer

	# Dash handling
	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()

	if is_dashing:
		velocity.x = direction * dash_speed
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			can_dash = false  
			dash_cooldown_timer = dash_cooldown  

	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			can_dash = true  

	move_and_slide()

func start_dash():
	is_dashing = true
	dash_timer = dash_time  
