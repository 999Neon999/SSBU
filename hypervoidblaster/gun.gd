extends Node2D

@export var bullet_scene: PackedScene  # Assign Bullet.tscn in Inspector
@export var fire_rate: float = 0.2  # Time between shots
@onready var nozzle = $Nozzle  # Nozzle where bullets spawn
@onready var flare = $Flare  # AnimatedSprite2D or AnimationPlayer


var can_shoot = true

func _process(delta):
	look_at(get_global_mouse_position())  # Rotate gun toward mouse

	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	if not can_shoot:
		return

	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)  # Add bullet to the same parent as the gun
	bullet.global_position = nozzle.global_position  # Spawn at nozzle position
	
	if flare is AnimationPlayer:
		flare.play("Flare")
	
	# Calculate direction based on gun rotation
	var shoot_direction = (get_global_mouse_position() - nozzle.global_position).normalized()
	bullet.direction = shoot_direction
