extends Node3D
var player: CharacterBody3D

func _ready() -> void:
	_build_sky()
	_build_grass()
	_build_walls()
	_spawn_enemies()
	_spawn_pickups()
	player = preload("res://Scripts/Player.gd").new()
	add_child(player)

func _build_sky() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var material := ProceduralSkyMaterial.new()
	material.sky_top_color = Color(0.12, 0.48, 0.92)
	material.sky_horizon_color = Color(0.48, 0.72, 0.96)
	sky.sky_material = material
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.68, 0.76, 0.9)
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -30, 0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

func _build_grass() -> void:
	var ground := StaticBody3D.new()
	add_child(ground)
	var mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(80, 80)
	mesh.mesh = plane
	var grass := ShaderMaterial.new()
	grass.shader = preload("res://Materials/Grass.gdshader")
	mesh.material_override = grass
	ground.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(80, 0.5, 80)
	collision.shape = shape
	collision.position.y = -0.25
	ground.add_child(collision)

func _build_walls() -> void:
	_add_wall(Vector3(0, 2.5, -40), Vector3(80, 5, 1))
	_add_wall(Vector3(0, 2.5, 40), Vector3(80, 5, 1))
	_add_wall(Vector3(-40, 2.5, 0), Vector3(1, 5, 80))
	_add_wall(Vector3(40, 2.5, 0), Vector3(1, 5, 80))

func _add_wall(pos: Vector3, size: Vector3) -> void:
	var wall := StaticBody3D.new()
	wall.position = pos
	add_child(wall)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.30, 0.38, 0.29)
	mesh.material_override = mat
	wall.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	wall.add_child(collision)

func _spawn_enemies() -> void:
	var positions := [Vector3(-15, 0, -18), Vector3(12, 0, -22), Vector3(25, 0, 10), Vector3(-25, 0, 12), Vector3(8, 0, 25), Vector3(-8, 0, -30)]
	for i in positions.size():
		var enemy = preload("res://Scripts/EnemyBean.gd").new()
		enemy.position = positions[i]
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
		pickup.position = entry[0]
		add_child(pickup)
