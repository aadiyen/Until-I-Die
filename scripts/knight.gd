extends CharacterBody2D


@export var max_health := 100
@export var SPEED := 200.0
@export var JUMP_VELOCITY := -400.0
@export var attack_damage := 25  
@export var attack_cooldown := 0.5  
@export var buff_duration := 5.0

var is_buff_active = false
var normal_speed
var normal_damage
var normal_health


var move_left = false
var move_right = false
var jump_pressed = false
var attack_pressed = false


@onready var sword_hitbox = $SwordHitbox
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $"../UI/HealthBar"
@onready var sword_sfx = $SwordSFX
@onready var sword_sfx2 = $SwordSFX2


var current_health = max_health
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking = false
var is_dead = false
var enemies_hit = []

var combo_stage = 0
var combo_timer = 0.0
var combo_max_delay = 0.5  


func _ready():
	sprite.animation_finished.connect(_on_animation_finished)
	sword_hitbox.monitoring = true
	normal_speed = SPEED
	normal_damage = attack_damage
	normal_health = max_health

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	
	if combo_stage > 0:
		combo_timer += delta
		if combo_timer > combo_max_delay:
			reset_combo()

	
	if not is_on_floor():
		velocity.y += gravity * delta

	
	if (Input.is_action_just_pressed("jump") or jump_pressed) and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
		jump_pressed = false

	
	if Input.is_action_just_pressed("attack") or attack_pressed:
		if not is_attacking:
			start_attack()
		elif is_attacking and combo_stage == 1:
			continue_combo()
		attack_pressed = false
	if not is_attacking:
		var direction = Input.get_axis("move_left", "move_right")  
		if move_left:
			direction -= 1
		if move_right:
			direction += 1

		if direction != 0:
			velocity.x = direction * SPEED
			sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	
	if sprite.animation == "attack" and sprite.frame == 3:
		if not sword_sfx.playing:
			sword_sfx.play()
	elif sprite.animation == "combo_attack" and sprite.frame == 4:
		if not sword_sfx2.playing:
			sword_sfx2.play()

	
	if not is_attacking:
		if velocity.y < 0 and not is_on_floor():
			sprite.play("jump")
		elif is_on_floor():
			if abs(velocity.x) > 0:
				sprite.play("run")
			else:
				sprite.play("idle")

	move_and_slide()


func start_attack():
	is_attacking = true
	velocity = Vector2.ZERO
	sprite.play("attack")  
	combo_stage = 1
	combo_timer = 0
	enemies_hit.clear()
	attack()

func continue_combo():
	combo_stage = 2
	combo_timer = 0
	sprite.play("combo_attack")
	enemies_hit.clear()
	attack()

func attack():
	var overlapping_areas = sword_hitbox.get_overlapping_areas()
	for area in overlapping_areas:
		var enemy = area.get_parent()
		if enemy.is_in_group("enemies") and enemy.has_method("take_damage") and enemy not in enemies_hit:
			enemy.take_damage(attack_damage)
			enemies_hit.append(enemy)

func _on_animation_finished():
	if sprite.animation == "attack" and combo_stage < 2:
		is_attacking = false
	elif sprite.animation == "combo_attack":
		reset_combo()
	elif sprite.animation == "die":
		queue_free()

func reset_combo():
	is_attacking = false
	combo_stage = 0
	combo_timer = 0
	enemies_hit.clear()


func take_damage(amount: int):
	if is_dead:
		return
	current_health -= amount
	if health_bar:
		health_bar.value = current_health
	if current_health <= 0:
		die()

func die():
	is_dead = true
	velocity = Vector2.ZERO
	sprite.play("die")
	$"../UI2/Label".text = "You Died!!"
	$"../UI2/GameUI/RestartButton".show()
	get_tree().paused = true

func activate_buff():
	if is_buff_active:
		return
	is_buff_active = true
	SPEED = normal_speed * 1.5
	attack_damage = normal_damage * 2
	current_health = clamp(current_health + 5, 0, max_health)
	if health_bar:
		health_bar.value = current_health
	var t = Timer.new()
	t.wait_time = buff_duration
	t.one_shot = true
	t.connect("timeout", Callable(self, "deactivate_buff"))
	add_child(t)
	t.start()

func deactivate_buff():
	SPEED = normal_speed
	attack_damage = normal_damage
	is_buff_active = false


func _on_LeftButton_pressed():
	move_left = true
func _on_LeftButton_released():
	move_left = false

func _on_RightButton_pressed():
	move_right = true
func _on_RightButton_released():
	move_right = false

func _on_JumpButton_pressed():
	jump_pressed = true
func _on_JumpButton_released():
	jump_pressed = false

func _on_AttackButton_pressed():
	attack_pressed = true
