extends Node2D

var Enemy = preload("res://game/entities/enemy/enemy.tscn")

@onready var item_1 := get_node("Item1")
@onready var item_2 := get_node("Item2")
@onready var item_3 := get_node("Item3")

# Called when the node enters the scene tree for the first time.
func _ready():
	item_1.change_stats({ #shotgun
		"sprite_path": ResourceLoader.load("res://game/items/guns/shotgun.png"),
		"damage": 3,
		"speed": 300,
		"amount": 3,
		"recoil": 0.3, #radiant
		"cooldown": 0.6
	})
	item_2.change_stats({ #rifle
		"sprite_path": ResourceLoader.load("res://game/items/guns/rifle.png"),
		"damage": 1,
		"speed": 400,
		"amount": 1,
		"recoil": 0.2, #radiant
		"cooldown": 0.1
	})
	item_3.change_stats({ #sniper
		"sprite_path": ResourceLoader.load("res://game/items/guns/sniper.png"),
		"damage": 5,
		"speed": 700,
		"amount": 1,
		"recoil": 0, #radiant
		"cooldown": 1
	})

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
