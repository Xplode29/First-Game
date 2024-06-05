extends CharacterBody2D

var maxHP := randf_range(5, 15)
var HP := maxHP
@onready var sprite := get_node("Sprite")
@onready var damageTimer: Timer = get_node("DamageTimer")
@onready var hp_bar := get_node("AnimatedSprite2D")

var speed := (15 - HP) * 15 + 100
var rotation_direction := 1
var rotation_speed := speed * 0.01

@onready var scene := get_parent()
@onready var player := scene.get_node("Player")

signal enemy_die()

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_die.connect(get_parent()._on_enemy_die)

func _process(delta):
	if scene.game_active:
		if velocity != Vector2.ZERO:
			if not (-10 < sprite.global_rotation_degrees and sprite.global_rotation_degrees < 10):
				rotation_direction *= -1
			sprite.rotate(rotation_direction * rotation_speed * delta)
		else:
			sprite.rotation = lerp(sprite.rotation, 0.0, 0.2)
	else:
		sprite.rotation = lerp(sprite.rotation, 0.0, 0.2)

func _physics_process(delta):
	if scene.game_active:
		var direction = global_position.direction_to(player.position)
		velocity = direction * speed
		velocity.normalized()
		
		var collision = move_and_collide(velocity * delta)
		if collision:
			if collision.get_collider().is_in_group("player"):
				collision.get_collider().take_damage(2, self)

func take_damage(amount, _sender):
	if damageTimer.time_left == 0:
		HP -= amount
		sprite.material.set_shader_parameter("flash_amount", 0.75)
		damageTimer.start()
		
		var frame_number = int((1 - (HP / maxHP)) * 46.0)
		hp_bar.set_frame(frame_number) #de 0 a 46
		
		if HP <= 0:
			enemy_die.emit()
			queue_free()

func _on_damage_timer_timeout():
	sprite.material.set_shader_parameter("flash_amount", 0)
	damageTimer.stop()
