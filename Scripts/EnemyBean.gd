extends CharacterBody3D
@export var max_health := 100.0
@export var move_speed := 3.4
var health := 100.0
var player: Node3D
var attack_cooldown := 0.0
var bar: Label3D

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	health = max_health
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.58
	shape.height = 1.8
	col.shape = shape
	col.position.y = 0.9
	add_child(col)
	var body := MeshInstance3D.new()
	var bean := SphereMesh.new()
	bean.radius = 0.68
	bean.height = 1.7
	body.mesh = bean
	body.position.y = 0.9
	body.scale = Vector3(0.85, 1, 0.82)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.86, 0.30, 0.19)
	body.material_override = mat
	add_child(body)
	bar = Label3D.new()
	bar.position.y = 2.1
	bar.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bar.font_size = 42
	bar.outline_size = 8
	bar.pixel_size = 0.003
	bar.no_depth_test = true
	add_child(bar)
	_update_bar()

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(0, attack_cooldown - delta)
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
	var offset := player.global_position - global_position
	offset.y = 0
	if offset.length() > 1.4:
		var dir := offset.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed * 5 * delta)
		velocity.z = move_toward(velocity.z, 0, move_speed * 5 * delta)
		if attack_cooldown <= 0:
			player.take_damage(12)
			attack_cooldown = 1.0
	if not is_on_floor():
		velocity.y -= float(ProjectSettings.get_setting("physics/3d/default_gravity")) * delta
	move_and_slide()

func take_damage(amount: float) -> void:
	health = maxf(0, health - amount)
	_update_bar()
	if health <= 0:
		queue_free()

func _update_bar() -> void:
	var count := int(ceil(health / max_health * 8))
	bar.text = "█".repeat(count) + "░".repeat(8 - count)
	bar.modulate = Color(0.25, 1, 0.28) if health > 50 else Color(1, 0.25, 0.15)
