extends Node3D
var player: CharacterBody3D

func _ready() -> void:
	_build_atmosphere()
	_build_floor()
	_build_perimeter()
	_build_cover()
	_spawn_enemies()
	_spawn_pickups()
	player = preload("res://Scripts/Player.gd").new()
	add_child(player)

func _build_atmosphere() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var material := ProceduralSkyMaterial.new()
	material.sky_top_color = Color(0.055, 0.068, 0.075)
	material.sky_horizon_color = Color(0.16, 0.17, 0.16)
	material.ground_bottom_color = Color(0.045, 0.05, 0.048)
	material.ground_horizon_color = Color(0.13, 0.14, 0.13)
	sky.sky_material = material
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.42, 0.44, 0.41)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_color = Color(0.72, 0.75, 0.72)
	sun.light_energy = 0.72
	sun.shadow_enabled = true
	add_child(sun)

func _build_floor() -> void:
	var ground := StaticBody3D.new()
	add_child(ground)
	var mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(80, 80)
	mesh.mesh = plane
	mesh.material_override = _material(Color(0.24, 0.25, 0.23), 0.0, 0.96)
	ground.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(80, 0.5, 80)
	collision.shape = shape
	collision.position.y = -0.25
	ground.add_child(collision)

func _build_perimeter() -> void:
	var wall_color := Color(0.19, 0.20, 0.19)
	_add_static_box(Vector3(0, 3, -40), Vector3(80, 6, 1), wall_color)
	_add_static_box(Vector3(0, 3, 40), Vector3(80, 6, 1), wall_color)
	_add_static_box(Vector3(-40, 3, 0), Vector3(1, 6, 80), wall_color)
	_add_static_box(Vector3(40, 3, 0), Vector3(1, 6, 80), wall_color)
	for x in [-30.0, -15.0, 0.0, 15.0, 30.0]:
		_add_static_box(Vector3(x, 3, -39.35), Vector3(0.55, 6, 0.35), Color(0.12, 0.13, 0.125))
		_add_static_box(Vector3(x, 3, 39.35), Vector3(0.55, 6, 0.35), Color(0.12, 0.13, 0.125))

func _build_cover() -> void:
	_add_static_box(Vector3(-11, 0.85, -8), Vector3(6, 1.7, 1.5), Color(0.28, 0.29, 0.27))
	_add_static_box(Vector3(12, 0.85, -12), Vector3(5, 1.7, 1.5), Color(0.28, 0.29, 0.27))
	_add_static_box(Vector3(0, 0.8, 13), Vector3(7, 1.6, 1.4), Color(0.25, 0.26, 0.24))
	_add_static_box(Vector3(-23, 0.8, 17), Vector3(3, 1.6, 3), Color(0.16, 0.18, 0.17))
	_add_static_box(Vector3(23, 0.8, -23), Vector3(3, 1.6, 3), Color(0.16, 0.18, 0.17))
	_add_static_box(Vector3(21, 0.8, 19), Vector3(4, 1.6, 2.2), Color(0.20, 0.21, 0.19))
	for x in [-27.0, 27.0]:
		_add_static_box(Vector3(x, 4, 0), Vector3(0.22, 8, 0.22), Color(0.09, 0.10, 0.095))
		_add_static_box(Vector3(x, 7.8, 0), Vector3(5, 0.22, 0.22), Color(0.09, 0.10, 0.095))

func _add_static_box(pos: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	add_child(body)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = _material(color, 0.12, 0.82)
	body.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)

func _material(color: Color, metal: float, rough: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metal
	mat.roughness = rough
	return mat

func _spawn_enemies() -> void:
	var positions := [Vector3(-15, 0, -18), Vector3(12, 0, -22), Vector3(25, 0, 10), Vector3(-25, 0, 12), Vector3(8, 0, 25), Vector3(-8, 0, -30)]
	for pos in positions:
		var enemy = preload("res://Scripts/EnemyBean.gd").new()
		enemy.position = pos
		add_child(enemy)

func _spawn_pickups() -> void:
	var positions := [
		[Vector3(-5, 0, -10), "ammo"], [Vector3(18, 0, -5), "health"],
		[Vector3(-20, 0, 0), "ammo"], [Vector3(0, 0, 20), "health"],
		[Vector3(28, 0, -25), "ammo"], [Vector3(-28, 0, 28), "health"]
	]
	for entry in positions:
		var pickup = preload("res://Scripts/Pickup.gd").new()
		pickup.pickup_type = entry[1]
		pickup.amount = 35 if entry[1] == "health" else 30
		pickup.position = entry[0]
		add_child(pickup)

func _material(color: Color, metal: float, rough: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metal
	mat.roughness = rough
	return mat
