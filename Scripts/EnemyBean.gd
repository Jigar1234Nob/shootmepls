extends CharacterBody3D

signal defeated

@export var is_boss := false
@export var max_health := 100.0
@export var move_speed := 3.1
var health := 100.0
var player: Node3D
var attack_cooldown := 0.0
var bar: Label3D
var ai_refresh := 0.0
var strafe_direction := 1.0
var strafe_timer := 0.0
var steering := Vector3.ZERO

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	add_to_group("enemies")
	health = max_health
	# Small random phase offsets prevent every enemy updating its steering on the same frame.
	ai_refresh = randf_range(0.0, 0.12)
	strafe_timer = randf_range(0.4, 1.4)
	strafe_direction = -1.0 if randf() < 0.5 else 1.0

	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.58 * (1.55 if is_boss else 1.0)
	shape.height = 1.8 * (1.55 if is_boss else 1.0)
	col.shape = shape
	col.position.y = 0.9
	add_child(col)

	# Featureless neon-red bean silhouette. No eyes, mouth, pupils or face decals.
	var body := MeshInstance3D.new()
	var bean := SphereMesh.new()
	bean.radius = 0.68
	bean.height = 1.7
	body.mesh = bean
	body.position.y = 0.9
	body.scale = Vector3(0.85, 1.0, 0.82) * (1.65 if is_boss else 1.0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.015, 0.035)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.0, 0.018)
	mat.emission_energy_multiplier = 2.2 if is_boss else 1.6
	mat.roughness = 0.72
	body.material_override = mat
	add_child(body)

	bar = Label3D.new()
	bar.position.y = 2.85 if is_boss else 2.05
	bar.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bar.font_size = 34
	bar.outline_size = 7
	bar.pixel_size = 0.0028
	bar.no_depth_test = true
	bar.modulate = Color(0.92, 0.95, 1.0)
	bar.visible = false
	add_child(bar)
	_update_bar()

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	ai_refresh -= delta
	strafe_timer -= delta

	if ai_refresh <= 0.0:
		ai_refresh = randf_range(0.085, 0.14)
		if player == null or not is_instance_valid(player):
			player = get_tree().get_first_node_in_group("player")
		if player != null and is_instance_valid(player):
			var offset := player.global_position - global_position
			offset.y = 0.0
			var distance := offset.length()
			if distance > 0.01:
				var toward := offset / distance
				var side := Vector3(-toward.z, 0.0, toward.x)
				if strafe_timer <= 0.0:
					strafe_timer = randf_range(0.65, 1.55)
					if randf() < 0.28:
						strafe_direction *= -1.0
				var strafe_strength := 0.28 if distance > 3.2 else 0.58
				var approach_strength := 1.0 if distance > 1.65 else -0.12
				steering = (toward * approach_strength + side * strafe_direction * strafe_strength).normalized()
				if distance <= 1.65 and attack_cooldown <= 0.0:
					player.take_damage(12 if not is_boss else 18)
					attack_cooldown = 1.0 if not is_boss else 0.8
				if steering.length_squared() > 0.01:
					look_at(global_position + steering, Vector3.UP)
		else:
			# If the player is temporarily unavailable, beans still patrol instead of freezing.
			if strafe_timer <= 0.0:
				strafe_timer = randf_range(1.0, 2.2)
				steering = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized()

	velocity.x = move_toward(velocity.x, steering.x * move_speed, move_speed * 4.0 * delta)
	velocity.z = move_toward(velocity.z, steering.z * move_speed, move_speed * 4.0 * delta)
	if not is_on_floor():
		velocity.y -= float(ProjectSettings.get_setting("physics/3d/default_gravity")) * delta
	else:
		velocity.y = 0.0
	move_and_slide()

func take_damage(amount: float) -> void:
	health = maxf(0.0, health - amount)
	bar.visible = true
	_update_bar()
	if health <= 0.0:
		defeated.emit()
		queue_free()

func _update_bar() -> void:
	if not is_instance_valid(bar):
		return
	var count := int(ceil(health / max_health * 8.0))
	bar.text = ("BOSS  " if is_boss else "") + "■".repeat(count) + "·".repeat(8 - count)
	bar.modulate = Color(0.92, 0.95, 1.0) if health > 50.0 else Color(1.0, 0.28, 0.24)
