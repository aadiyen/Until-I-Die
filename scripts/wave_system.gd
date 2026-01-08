extends Node2D

@export var enemy_scenes: Array[PackedScene] = []  

var current_wave = 0
var enemies_remaining = 0

@onready var wave_label = $UI2/WaveLabel

@onready var spawners = [
	$EnemySpawner,
	$EnemySpawner2,
	$EnemySpawner3,
	$EnemySpawner4
]

func _ready():
	update_wave_label()
	start_next_wave()

func start_next_wave():
	current_wave += 1
	wave_label.text = "Wave: %d" % current_wave

	var enemies_to_spawn = current_wave * 3
	enemies_remaining = enemies_to_spawn

	for i in range(enemies_to_spawn):
		spawn_enemy()

func spawn_enemy():
	if enemy_scenes.is_empty():
		print("Enemy scenes not assigned.")
		return

	var random_enemy_scene = enemy_scenes.pick_random()
	var enemy = random_enemy_scene.instantiate()

	var spawner = spawners.pick_random()
	enemy.global_position = spawner.global_position
	add_child(enemy)

	enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))

func _on_enemy_died(enemy_node):
	enemies_remaining -= 1
	if enemies_remaining <= 0:
		await get_tree().create_timer(2.0).timeout
		start_next_wave()

func update_wave_label():
	print("Wave label updated:", current_wave)
	
	wave_label.text = "Wave: %d" % current_wave
