extends Node3D

var player: CharacterBody3D

func _ready() -> void:
	_build_sky()
	_build_baseplate()
	player = preload("res://Scripts/Player.gd").new()
	player.position = Vector3(0, 0.1, 0)
	add_child(player)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build_sky() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.12, 0.48, 0.92)
	sky_material.sky_horizon_color = Color(0.48, 0.72, 0.96)
	sky_material.ground_bottom_color = Color(0.22, 0.38, 0.2)
	sky_material.ground_horizon_color = Color(0.48, 0.72, 0.96)
	sky_material.sun_angle_max = 18.0
	sky_material.use_debanding = true
	sky.sky_material = sky_material
	env.sky = sky
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.68, 0.76, 0.9)
	env.ambient_light_energy = 0.8
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -30, 0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

func _build_baseplate() -> void:
	var ground := StaticBody3D.new()
	ground.name = "GreenBaseplate"
	add_child(ground)

	var mesh_instance := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(500, 500)
	mesh_instance.mesh = plane
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color(0.18, 0.62, 0.22)
	grass.roughness = 1.0
	grass.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = grass
	ground.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(500, 0.5, 500)
	collision.shape = shape
	collision.position.y = -0.25
	ground.add_child(collision)
