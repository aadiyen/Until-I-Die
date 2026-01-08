extends Area2D

@onready var collision_shape = $CollisionShape2D

func enable_hitbox():
	collision_shape.set_deferred("disabled", false)

func disable_hitbox():
	collision_shape.set_deferred("disabled", true)
