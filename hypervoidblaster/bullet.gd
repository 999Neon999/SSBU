extends Node2D

@export var speed: float = 1000.0  
@export var lifespan: float = 2.0  

var direction = Vector2.ZERO  

func _ready():
	await get_tree().create_timer(lifespan).timeout
	queue_free()  # Destroy bullet after lifespan

func _physics_process(delta):
	global_position += direction * speed * delta
