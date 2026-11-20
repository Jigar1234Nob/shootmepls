extends Node3D

var player: CharacterBody3D

func _ready() -> void:
	_build_sky()
	_build_grass()
	_build_targets()
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

func _build_grass() -> void:
	var ground := StaticBody3D.new()
	ground.name = "GrassField"
	add_child(ground)

	var mesh_instance := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(500, 500)
	mesh_instance.mesh = plane
	var grass := ShaderMaterial.new()
	grass.shader = preload("res://Materials/Grass.gdshader")
	mesh_instance.material_override = grass
	ground.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(500, 0.5, 500)
	collision.shape = shape
	collision.position.y = -0.25
	ground.add_child(collision)

func _build_targets() -> void:
	var target_script = preload("res://Scripts/Target.gd")
	var positions := [
		Vector3(0, 0, -18), Vector3(7, 0, -24), Vector3(-8, 0, -28),
		Vector3(16, 0, -12), Vector3(-17, 0, -15), Vector3(24, 0, 5),
		Vector3(-24, 0, 7), Vector3(5, 0, 22), Vector3(-10, 0, 25)
	]
	for i in positions.size():
		var target := StaticBody3D.new()
		target.set_script(target_script)
		target.position = positions[i]
		target.name = "Target_%02d" % (i + 1)
		add_child(target)
