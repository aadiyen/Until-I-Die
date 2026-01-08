extends Node2D


@export var enemy_scene: PackedScene

@onready var spawn_point: Node2D = $SpawnPoint
@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if not enemy_scene:
		print("Enemy scene not assigned!")
		return

	var enemy_instance = enemy_scene.instantiate()

	
	if not spawn_point:
		print("Spawn point not found!")
		return

	enemy_instance.position = spawn_point.global_position

	
	var parent_node = get_parent()
	if parent_node:
		parent_node.add_child(enemy_instance)
	else:
		print("Parent node is null!")   
