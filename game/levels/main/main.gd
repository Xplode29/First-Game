extends Node2D

@onready var wave_timer := get_node("WaveTimer")
@onready var player := get_node("Player")
@onready var camera : Camera2D = player.get_node("Camera2D")

@onready var hud := get_node("HUD")
@onready var message := hud.get_node("Message")
@onready var killCountHud := hud.get_node("KillCount")

var Enemy = preload("res://game/entities/enemy/enemy.tscn")
var Item = preload("res://game/items/item.tscn")

var killCount = 0
var mobs_in_wave = 20
var game_active = false

@onready var shotgun_stats = { #shotgun
	"sprite_path": ResourceLoader.load("res://game/items/guns/shotgun.png"),
	"damage": 4,
	"speed": 300,
	"amount": 3,
	"zoom": 1,
	"recoil": 0.3, #radiant
	"cooldown": 0.6
}
@onready var rifle_stats = { #rifle
	"sprite_path": ResourceLoader.load("res://game/items/guns/rifle.png"),
	"damage": 1,
	"speed": 400,
	"amount": 1,
	"zoom": 1,
	"recoil": 0.2, #radiant
	"cooldown": 0.1
}
@onready var sniper_stats = { #sniper
	"sprite_path": ResourceLoader.load("res://game/items/guns/sniper.png"),
	"damage": 8,
	"speed": 700,
	"amount": 1,
	"zoom": 0.75,
	"recoil": 0, #radiant
	"cooldown": 1
}

# Called when the node enters the scene tree for the first time.
func _ready():
	player.die.connect(_on_player_die)
	
	message.text = "SURVIVE"
	start_wave()

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _process(delta):
	if not game_active:
		camera.position = Vector2(0, 0).lerp(-player.position, 1 - wave_timer.time_left)

func spawn_enemy_randomly():
	var spawned_enemy = Enemy.instantiate()
	call_deferred("add_child", spawned_enemy)
	var signPos = [-1, 1] #list to choose from
	spawned_enemy.position = Vector2(
		randf_range(512, 1920) * signPos[randi() % signPos.size()], 
		randf_range(256, 1080) * signPos[randi() % signPos.size()]
	)

func spawn_item(stats):
	var new_item = Item.instantiate()
	add_child(new_item)
	#call_deferred("add_child", new_item)
	var signPos = [-1, 1] #list to choose from
	new_item.position = Vector2(
		randf_range(512, 1920) * signPos[randi() % signPos.size()], 
		randf_range(256, 1080) * signPos[randi() % signPos.size()]
	)
	new_item.change_stats(stats)

func start_wave():
	game_active = false
	player.visible = false
	killCountHud.visible = false
	killCount = 0
	
	message.visible = true
	
	player.set_velocity(Vector2(0, 0))
	
	wave_timer.start()

func _on_wave_timer_timeout():
	game_active = true
	message.visible = false
	player.visible = true
	camera.position = Vector2(0, 0)
	player.set_position(Vector2(0, 0))
	player.heal(player.maxHP)
	
	for i in range(mobs_in_wave):
		spawn_enemy_randomly()
	
	killCountHud.visible = true
	killCountHud.text = "{killCount}/{mobs_in_wave}".format({"killCount": killCount, "mobs_in_wave": mobs_in_wave})
	
	wave_timer.stop()
	
	if mobs_in_wave == 25: spawn_item(shotgun_stats)
	if mobs_in_wave == 30: spawn_item(rifle_stats)
	if mobs_in_wave == 35: spawn_item(sniper_stats)

func _on_enemy_die():
	killCount += 1
	killCountHud.text = "{killCount}/{mobs_in_wave}".format({"killCount": killCount, "mobs_in_wave": mobs_in_wave})
	if killCount >= mobs_in_wave:
		mobs_in_wave += 5
		message.text = "NEXT WAVE"
		start_wave()

func _on_player_die():
	message.text = "YOU DIED"
	game_active = false
	message.visible = true
