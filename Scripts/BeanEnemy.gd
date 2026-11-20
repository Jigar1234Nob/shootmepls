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
	shape.height = 1.55
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.78
	add_child(collision)
	body_mesh = MeshInstance3D.new()
	var bean := SphereMesh.new()
	bean.radius = 0.58
	bean.height = 1.45
	body_mesh.mesh = bean
	body_mesh.position.y = 0.78
	body_mesh.scale = Vector3(0.88, 1.0, 0.78)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.18, randf_range(0.48, 0.85), randf_range(0.28, 0.55))
	mat.roughness = 0.78
	mat.metallic = 0.02
	body_mesh.material_override = mat
	add_child(body_mesh)
	_add_face()
	if player == null:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0] as FPSPlayer

func _add_face() -> void:
	for x in [-0.17, 0.17]:
		var eye := MeshInstance3D.new()
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.075
		eye_mesh.height = 0.15
		eye.mesh = eye_mesh
		eye.position = Vector3(x, 1.03, -0.43)
		var eye_mat := StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.97, 0.98, 1.0)
		eye.material_override = eye_mat
		add_child(eye)
		var pupil := MeshInstance3D.new()
		var pupil_mesh := SphereMesh.new()
		pupil_mesh.radius = 0.032
		pupil_mesh.height = 0.064
		pupil.mesh = pupil_mesh
		pupil.position = Vector3(x, 1.03, -0.49)
		var pupil_mat := StandardMaterial3D.new()
		pupil_mat.albedo_color = Color(0.025, 0.03, 0.04)
		pupil.material_override = pupil_mat
		add_child(pupil)

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
		var mat := body_mesh.material_override as StandardMaterial3D
		mat.albedo_color = Color(1.0, 0.35, 0.28)
		var timer := get_tree().create_timer(0.09)
		timer.timeout.connect(func():
			if is_instance_valid(body_mesh):
				mat.albedo_color = Color(0.18, 0.68, 0.38)
		)
