extends Area2D

@export var enemy: Node2D

func _on_area_entered(area: Area2D) -> void:
	if area.name == "SwordHitbox":
		print("Hit by Sword!")
		if enemy and enemy.has_method("take_damage"):
			enemy.take_damage(100)  
