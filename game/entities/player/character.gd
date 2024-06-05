extends CharacterBody2D

const acceleration = 60000.0
var max_speed = 200.0
const friction = 0.2
var direction

var rotation_direction = 1
var rotation_speed = max_speed * 0.01

var maxHP := 10.0
var HP := maxHP
var damaged = false
@onready var sprite = get_node("Sprite")
@onready var damageTimer: Timer = get_node("DamageTimer")
@onready var hp_bar := get_node("AnimatedSprite2D")
@onready var gun := get_node("Gun")

@onready var scene := get_parent()

signal die()

func _ready():
	get_node("Gun").shoot.connect(_on_player_shoot)

func _process(delta):
	if scene.game_active:
		if direction != Vector2.ZERO:
			if not (-10 < sprite.global_rotation_degrees and sprite.global_rotation_degrees < 10):
				rotation_direction *= -1
			sprite.rotate(rotation_direction * rotation_speed * delta)
		else:
			sprite.rotation = lerp(sprite.rotation, 0.0, 0.2)
	else:
		sprite.rotation = lerp(sprite.rotation, 0.0, 0.2)

func _physics_process(_delta):
	if scene.game_active:
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		direction = direction.normalized()
		
		if direction != Vector2.ZERO:
			velocity += direction * acceleration
			velocity = velocity.limit_length(max_speed)
		else:
			velocity = velocity.lerp(Vector2.ZERO, friction)
			rotation = lerp(rotation, 0.0, friction)
	else:
		velocity = velocity.lerp(Vector2.ZERO, 0.05)
	move_and_slide()

func take_damage(amount, sender):
	if not damaged and scene.game_active:
		HP -= amount
		sprite.material.set_shader_parameter("flash_amount", 0.75)
		damageTimer.start()
		velocity = sender.velocity * 5 #knockback
		damaged = true
		
		var frame_number = int((1 - (HP / maxHP)) * 46.0)
		hp_bar.set_frame(frame_number) #de 0 a 46
		
		if HP <= 0:
			visible = false
			die.emit()

func heal(amount):
	HP += amount
	var frame_number
	if HP >= maxHP:
		HP = maxHP
		frame_number = 0
	else:
		frame_number = int((1 - (HP / maxHP)) * 46.0)
	
	hp_bar.set_frame(frame_number) #de 0 a 46

func _on_damage_timer_timeout():
	sprite.material.set_shader_parameter("flash_amount", 0)
	damageTimer.stop()
	damaged = false

func _on_player_shoot(Bullet, bullet_direction, bullet_location):
	if scene.game_active:
		var spawned_bullet : Node2D = Bullet.instantiate()
		get_parent().add_child(spawned_bullet)
		spawned_bullet.rotation = bullet_direction
		spawned_bullet.position = bullet_location
		spawned_bullet.velocity = spawned_bullet.velocity.rotated(bullet_direction)
		
		spawned_bullet.damage = gun.gun_stats["damage"]
		spawned_bullet.speed = gun.gun_stats["speed"]
