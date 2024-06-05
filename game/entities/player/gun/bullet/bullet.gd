extends Area2D

var velocity = Vector2.RIGHT
var speed = 300
var damage = 1
@onready var scene := get_parent()

func _process(delta):
	if not scene.game_active:
		queue_free()

func _physics_process(delta):
	position += velocity * delta * speed

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage, self)
		queue_free()

func _on_screen_entered():
	pass # Replace with function body.

func _on_screen_exited():
	queue_free()
