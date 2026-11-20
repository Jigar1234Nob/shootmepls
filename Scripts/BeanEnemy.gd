extends CharacterBody3D
class_name BeanEnemy

signal defeated(reward: int)

var player: FPSPlayer
var health := 65
var move_speed := 3.2
var attack_range := 11.0
var shoot_cooldown := 1.7
var shoot_timer := 0.8
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var body_mesh: MeshInstance3D
var hit_flash := 0.0

func _ready() -> void:
	add_to_group("enemies")
	var shape := CapsuleShape3D.new()
	shape.radius = 0.48
	shape.height = 1.75
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.88
	add_child(collision)
	body_mesh = MeshInstance3D.new()
	var bean := SphereMesh.new()
	bean.radius = 0.58
	bean.height = 1.45
	body_mesh.mesh = bean
	body_mesh.position.y = 0.78
	body_mesh.scale = Vector3(0.88, 1.0, 0.78)
	var mat := ShaderMaterial.new()
	mat.shader = load("res://Materials/ProceduralSurface.gdshader")
	mat.set_shader_parameter("base_color", Color(0.22, 0.24, 0.21))
	mat.set_shader_parameter("roughness_value", 0.78)
	mat.set_shader_parameter("metallic_value", 0.02)
	body_mesh.material_override = mat
	add_child(body_mesh)
	if player == null:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0] as FPSPlayer

func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player) or player.health <= 0:
		return
	if not is_on_floor():
		velocity.y -= gravity * delta
	var to_player := player.global_position - global_position
	var flat := Vector3(to_player.x, 0, to_player.z)
	var distance := flat.length()
	if distance > 7.0:
		var dir := flat.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, 9.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 9.0 * delta)
	if distance > 0.1:
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	shoot_timer -= delta
	if distance <= attack_range and shoot_timer <= 0.0:
		_fire_at_player()
		shoot_timer = shoot_cooldown + randf_range(-0.3, 0.45)
	if body_mesh:
		var bob := sin(float(Time.get_ticks_msec()) * 0.006 + float(get_instance_id() % 100)) * 0.035
		body_mesh.position.y = 0.78 + bob
		body_mesh.rotation.z = sin(float(Time.get_ticks_msec()) * 0.004) * 0.025
	if hit_flash > 0:
		hit_flash -= delta
	move_and_slide()

func _fire_at_player() -> void:
	if player == null:
		return
	var start := global_position + Vector3.UP * 1.0
	var finish := player.global_position + Vector3.UP * 1.25
	var query := PhysicsRayQueryParameters3D.create(start, finish)
	query.exclude = [get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if not result.is_empty() and result.collider == player:
		player.take_damage(randi_range(5, 9))

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		var reward := randi_range(10, 36)
		defeated.emit(reward)
		queue_free()
	else:
		var mat := body_mesh.material_override as ShaderMaterial
		if mat:
			mat.set_shader_parameter("base_color", Color(0.70, 0.38, 0.28))
			var timer := get_tree().create_timer(0.09)
			timer.timeout.connect(func():
				if is_instance_valid(body_mesh) and is_instance_valid(mat):
					mat.set_shader_parameter("base_color", Color(0.22, 0.24, 0.21))
			)
