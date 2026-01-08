extends Node2D

@export var enemy_scene: PackedScene

@onready var spawn_point: Node2D = $SpawnPoint
@onready var spawn_timer: Timer = $SpawnTimer


var min_wait_time := 0.5
var spawn_reduce_step := 0.2
var spawn_adjust_interval := 10.0  
var time_since_last_adjust := 0.0

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _process(delta):
	time_since_last_adjust += delta
	if time_since_last_adjust >= spawn_adjust_interval:
		increase_spawn_rate()
		time_since_last_adjust = 0.0

func increase_spawn_rate():
	if spawn_timer.wait_time > min_wait_time:
		spawn_timer.wait_time = max(min_wait_time, spawn_timer.wait_time - spawn_reduce_step)
		print("Spawn rate increased! New wait_time: ", spawn_timer.wait_time)

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
