extends CharacterBody2D

@export var max_health := 10.0
@export var attack_range := 40.0
@export var attack_damage := 1.0
@export var attack_cooldown := 1.0
@export var speed := 60.0
@export var chase_range := 1000.0

const GRAVITY := 1000.0

var can_attack := true
var is_attacking := false
var current_health := max_health
var is_dead := false

@onready var knight: CharacterBody2D = $"../knight"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	if is_dead or not knight:
		return

	
	self.velocity.y += GRAVITY * delta


	var distance = position.distance_to(knight.position)

	
	if distance < attack_range and can_attack and not is_attacking:
		attack()
		return


	if not is_attacking:
		if distance < chase_range:
			var direction = (knight.position - position).normalized()
			self.velocity.x = direction.x * speed
		else:
			self.velocity.x = 0

		
		if abs(self.velocity.x) > 1:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("idle")

		animated_sprite.flip_h = self.velocity.x < 0

	
	move_and_slide()

func attack():
	is_attacking = true
	can_attack = false
	self.velocity.x = 0

	animated_sprite.play("attack")
	print("Skeleton attacked and dealt ", attack_damage, " damage!")

	
	if position.distance_to(knight.position) <= attack_range: 
		if knight.has_method("take_damage"):
			knight.take_damage(attack_damage)

	await animated_sprite.animation_finished
	is_attacking = false

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func take_damage(amount: int):
	if is_dead:
		return

	current_health -= amount
	print("Skeleton took", amount, "damage! Remaining:", current_health)
	animated_sprite.play("take_hit")
	if current_health <= 0:
		die()

func die():
	is_dead = true
	self.velocity = Vector2.ZERO
	#animated_sprite.play("die")
	ScoreManager.add_score(1)
	print("Skeleton Died!")
	await animated_sprite.animation_finished
	queue_free()

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.name == "Swordhitbox":
		var player = area.get_parent()
		if player.has_meta("is_attacking") and player.is_attacking:
			print("Skeleton took", 100, "damage")
			take_damage(100)


	
	
