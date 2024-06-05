extends Node2D

signal shoot(bullet, direction, location)

var gun_stats := {
	"sprite_path": ResourceLoader.load("res://game/items/guns/gun.png"),
	"damage": 1,
	"speed": 300,
	"amount": 1,
	"zoom": 1,
	"recoil": 0.05, #radiant
	"cooldown": 0.3
}

var Bullet = preload("res://game/entities/player/gun/bullet/bullet.tscn")
@onready var output = get_node("Output")
@onready var cooldownTimer: Timer = get_node("CooldownTimer")
@onready var texture_rect: TextureRect = get_node("TextureRect")
@onready var sound_shoot := get_node("SfxrStreamPlayer2D")

@onready var scene := get_parent().get_parent()
@onready var camera : Camera2D = get_parent().get_node("Camera2D")

var mouse_left_down: bool = false

func _ready():
	apply_stats()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pass
		if event.button_index == 1: mouse_left_down = event.is_pressed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if scene.game_active:
		look_at(get_global_mouse_position())
		
		if mouse_left_down:
			if cooldownTimer.time_left == 0:
				for i in range(gun_stats["amount"]):
					shoot.emit(
						Bullet,
						rotation + randf_range(-gun_stats["recoil"], gun_stats["recoil"]),
						output.global_position
					)
				cooldownTimer.start()
				sound_shoot.play()

func _on_cooldown_timeout():
	cooldownTimer.stop()

func switch_gun(new_gun: Dictionary) -> Dictionary:
	var dropped_gun = gun_stats.duplicate()
	gun_stats = new_gun
	apply_stats()
	return dropped_gun

func apply_stats():
	texture_rect.texture = gun_stats["sprite_path"]
	cooldownTimer.set_wait_time(gun_stats["cooldown"])
	camera.zoom.x = gun_stats["zoom"]
	camera.zoom.y = gun_stats["zoom"]
	
	sound_shoot.set_pitch_scale((1 - gun_stats["cooldown"]) + 0.3)
	sound_shoot.set_volume_db((gun_stats["cooldown"]) * 10 - 20)
