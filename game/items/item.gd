extends Area2D

var amplitude := 10.0
var frequency := 3.0
var time := 0.0

var gun_stats := {
	"sprite_path": ResourceLoader.load("res://game/items/guns/gun.png"),
	"damage": 1,
	"speed": 300,
	"amount": 1,
	"zoom": 1,
	"recoil": 0.05, #radiant
	"cooldown": 0.2
}

@onready var sprite := get_node("Sprite")
@onready var shadow := get_node("Shadow")
@onready var sound_pickup := get_node("SfxrStreamPlayer2D")
@onready var pickup_timer : Timer = get_node("PickupTimer")
@onready var pos : Vector2 = sprite.get_position()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta * frequency
	shadow.material.set_shader_parameter("flash_amount", (1 - sin(time)) / 2)
	sprite.set_position(pos + Vector2(0, sin(time) * amplitude))

func change_stats(new_gun: Dictionary):
	gun_stats = new_gun.duplicate()
	sprite.set_texture(gun_stats["sprite_path"])

func _on_body_entered(body):
	if body.is_in_group("player") and pickup_timer.time_left == 0:
		pickup_timer.start()
		change_stats(body.gun.switch_gun(gun_stats))
		sound_pickup.play()
		#queue_free()

func _on_pickup_timer_timeout():
	pickup_timer.stop()
