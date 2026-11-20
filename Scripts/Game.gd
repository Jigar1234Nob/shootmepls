extends Node3D
var player: CharacterBody3D
var main_menu: Control
var menu_layer: CanvasLayer
var menu_status: Label
var match_started := false
var current_wave := 1
var wave_transition := false
var wave_label: Label
var controls_page: Control

func _ready() -> void:
	_build_atmosphere()
	_show_start_screen()

func _show_start_screen() -> void:
	menu_layer = CanvasLayer.new()
	menu_layer.layer = 20
	add_child(menu_layer)
	main_menu = Control.new()
	main_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_layer.add_child(main_menu)

	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.018, 0.024, 0.025)
	main_menu.add_child(background)

	var left_bar := ColorRect.new()
	left_bar.color = Color(0.53, 0.55, 0.43)
	left_bar.position = Vector2(0, 0)
	left_bar.size = Vector2(7, 720)
	left_bar.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	left_bar.offset_right = 7
	main_menu.add_child(left_bar)

	var header := Label.new()
	header.text = "S H O O T   M E   P L S"
	header.position = Vector2(64, 34)
	header.add_theme_font_size_override("font_size", 18)
	header.add_theme_color_override("font_color", Color(0.77, 0.78, 0.70))
	main_menu.add_child(header)

	var version := Label.new()
	version.text = "TACTICAL COMBAT SIMULATION     /     BUILD 01"
	version.position = Vector2(64, 66)
	version.add_theme_font_size_override("font_size", 10)
	version.add_theme_color_override("font_color", Color(0.43, 0.46, 0.43))
	main_menu.add_child(version)

	var title := Label.new()
	title.text = "SHOOT\nME PLS"
	title.position = Vector2(72, 188)
	title.add_theme_font_size_override("font_size", 76)
	title.add_theme_color_override("font_color", Color(0.88, 0.89, 0.83))
	title.add_theme_constant_override("line_spacing", -8)
	main_menu.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "ONE OPERATOR. NO BACKUP. NO SECOND CHANCES."
	subtitle.position = Vector2(78, 380)
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", Color(0.61, 0.64, 0.57))
	main_menu.add_child(subtitle)

	var menu_panel := PanelContainer.new()
	menu_panel.position = Vector2(78, 455)
	menu_panel.custom_minimum_size = Vector2(330, 190)
	menu_panel.add_theme_stylebox_override("panel", _menu_panel_style())
	main_menu.add_child(menu_panel)
	var menu_items := VBoxContainer.new()
	menu_items.add_theme_constant_override("separation", 9)
	menu_panel.add_child(menu_items)

	var play := _menu_button("DEPLOY  /  START MATCH", true)
	play.pressed.connect(_start_match)
	menu_items.add_child(play)
	var controls := _menu_button("CONTROLS", false)
	controls.pressed.connect(_show_controls)
	menu_items.add_child(controls)
	var credits := Label.new()
	credits.text = "CREATED BY JIGAR RAI"
	credits.position = Vector2(78, 640)
	credits.add_theme_font_size_override("font_size", 11)
	credits.add_theme_color_override("font_color", Color(0.55, 0.58, 0.51))
	main_menu.add_child(credits)
	var quit := _menu_button("QUIT TO DESKTOP", false)
	quit.pressed.connect(func(): get_tree().quit())
	menu_items.add_child(quit)

	menu_status = Label.new()
	menu_status.text = "READY FOR DEPLOYMENT"
	menu_status.position = Vector2(78, 670)
	menu_status.add_theme_font_size_override("font_size", 10)
	menu_status.add_theme_color_override("font_color", Color(0.57, 0.62, 0.48))
	main_menu.add_child(menu_status)

	var right_title := Label.new()
	right_title.text = "MISSION BRIEF"
	right_title.position = Vector2(790, 175)
	right_title.add_theme_font_size_override("font_size", 13)
	right_title.add_theme_color_override("font_color", Color(0.68, 0.71, 0.62))
	main_menu.add_child(right_title)

	var briefing := Label.new()
	briefing.text = "OPERATION: IRON YARD\n\nHOSTILE CONTACTS: 06\nAREA: INDUSTRIAL TRAINING ZONE\nOBJECTIVE: SURVIVE\n\nSCAVENGE AMMUNITION AND MEDICAL\nSUPPLIES. HOSTILES WILL PURSUE ON SIGHT."
	briefing.position = Vector2(790, 208)
	briefing.custom_minimum_size = Vector2(390, 190)
	briefing.add_theme_font_size_override("font_size", 14)
	briefing.add_theme_color_override("font_color", Color(0.72, 0.74, 0.68))
	briefing.add_theme_constant_override("line_spacing", 8)
	main_menu.add_child(briefing)

	var divider := ColorRect.new()
	divider.position = Vector2(790, 430)
	divider.size = Vector2(390, 1)
	divider.color = Color(0.28, 0.31, 0.28)
	main_menu.add_child(divider)

	var rules := Label.new()
	rules.text = "FIELD RULES\n\n01   WATCH YOUR AMMUNITION\n02   USE COVER\n03   KEEP MOVING\n04   DO NOT GET SURROUNDED"
	rules.position = Vector2(790, 452)
	rules.add_theme_font_size_override("font_size", 12)
	rules.add_theme_color_override("font_color", Color(0.57, 0.60, 0.55))
	rules.add_theme_constant_override("line_spacing", 7)
	main_menu.add_child(rules)

	var footer := Label.new()
	footer.text = "SHOOT ME PLS  /  TACTICAL SURVIVAL"
	footer.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	footer.position = Vector2(-360, -34)
	footer.add_theme_font_size_override("font_size", 10)
	footer.add_theme_color_override("font_color", Color(0.39, 0.42, 0.39))
	main_menu.add_child(footer)

func _menu_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.043, 0.041, 0.98)
	style.border_color = Color(0.25, 0.29, 0.25)
	style.set_border_width_all(1)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style

func _menu_button(label_text: String, highlighted: bool) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(300, 44)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 14)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.31, 0.34, 0.27) if highlighted else Color(0.055, 0.065, 0.06)
	normal.border_color = Color(0.50, 0.53, 0.42) if highlighted else Color(0.19, 0.22, 0.19)
	normal.set_border_width_all(1)
	normal.content_margin_left = 14
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color(0.40, 0.43, 0.33) if highlighted else Color(0.10, 0.12, 0.10)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_color_override("font_color", Color(0.91, 0.92, 0.86))
	return button

func _show_controls() -> void:
	main_menu.visible = false
	var controls_layer := CanvasLayer.new()
	controls_layer.layer = 21
	controls_layer.name = "ControlsLayer"
	add_child(controls_layer)
	controls_page = Control.new()
	controls_page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	controls_layer.add_child(controls_page)
	var background := ColorRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.018, 0.024, 0.025)
	controls_page.add_child(background)
	var heading := Label.new()
	heading.text = "FIELD MANUAL  /  CONTROLS"
	heading.position = Vector2(76, 58)
	heading.add_theme_font_size_override("font_size", 34)
	heading.add_theme_color_override("font_color", Color(0.86, 0.88, 0.82))
	controls_page.add_child(heading)
	var details := Label.new()
	details.text = "KEYBOARD & MOUSE\nWASD          MOVE\nMOUSE         LOOK / AIM\nLEFT CLICK    FIRE\nSPACE         JUMP\nLEFT SHIFT    SPRINT\nESC           PAUSE\n\nCONTROLLER\nLEFT STICK    MOVE\nRIGHT STICK   LOOK / AIM\nA / CROSS     JUMP\nRB / R1       FIRE\nX / SQUARE    ALTERNATE FIRE\nL3            SPRINT\nSTART         PAUSE\n\nSURVIVAL\nCollect limited ammunition and medical supplies.\nEvery fifth wave contains a heavy boss with five times the health."
	details.position = Vector2(82, 145)
	details.add_theme_font_size_override("font_size", 19)
	details.add_theme_color_override("font_color", Color(0.72, 0.75, 0.69))
	controls_page.add_child(details)
	var back := _menu_button("BACK TO MAIN MENU", true)
	back.position = Vector2(82, 610)
	back.pressed.connect(func():
		controls_layer.queue_free()
		controls_page = null
		main_menu.visible = true
	)
	controls_page.add_child(back)
	var credit := Label.new()
	credit.text = "SHOOT ME PLS  /  CREATED BY JIGAR RAI"
	credit.position = Vector2(790, 650)
	credit.add_theme_font_size_override("font_size", 12)
	credit.add_theme_color_override("font_color", Color(0.52, 0.55, 0.49))
	controls_page.add_child(credit)

func _start_match() -> void:
	if match_started:
		return
	match_started = true
	main_menu.queue_free()
	_build_floor()
	_build_perimeter()
	_build_cover()
	_build_map_details()
	player = preload("res://Scripts/Player.gd").new()
	add_child(player)
	current_wave = 1
	_spawn_wave(current_wave)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _spawn_wave(wave: int) -> void:
	wave_transition = false
	if is_instance_valid(player) and player.has_method("set_wave"):
		player.set_wave(wave)
	var count := mini(6 + (wave - 1) * 2, 30)
	var boss_wave := wave % 5 == 0
	for i in range(count):
		var enemy = preload("res://Scripts/EnemyBean.gd").new()
		enemy.position = _wave_spawn_position(i, count)
		enemy.max_health = 500.0 if boss_wave and i == 0 else 100.0 + float(wave - 1) * 12.0
		enemy.is_boss = boss_wave and i == 0
		enemy.move_speed = 2.65 if enemy.is_boss else minf(3.1 + float(wave - 1) * 0.08, 4.8)
		enemy.defeated.connect(_on_enemy_defeated)
		add_child(enemy)
	_spawn_wave_pickups(wave)

func _wave_spawn_position(index: int, total: int) -> Vector3:
	var angle := TAU * float(index) / float(maxi(total, 1)) + randf_range(-0.18, 0.18)
	var radius := randf_range(22.0, 31.0)
	return Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)

func _spawn_wave_pickups(wave: int) -> void:
	# Remove uncollected supplies so stock never accumulates between waves.
	for old_pickup in get_tree().get_nodes_in_group("wave_pickups"):
		old_pickup.queue_free()
	# Supplies are deliberately scarce and are replenished only at wave start.
	var ammo_count := 1 if wave < 4 else 2
	var health_count := 1 if wave < 3 else (2 if wave % 5 == 0 else 1)
	for i in range(ammo_count):
		var pickup = preload("res://Scripts/Pickup.gd").new()
		pickup.add_to_group("wave_pickups")
		pickup.pickup_type = "ammo"
		pickup.amount = 18 if wave < 5 else 14
		pickup.position = Vector3(randf_range(-27, 27), 0, randf_range(-27, 27))
		add_child(pickup)
	for i in range(health_count):
		var pickup = preload("res://Scripts/Pickup.gd").new()
		pickup.add_to_group("wave_pickups")
		pickup.pickup_type = "health"
		pickup.amount = 25
		pickup.position = Vector3(randf_range(-27, 27), 0, randf_range(-27, 27))
		add_child(pickup)

func _on_enemy_defeated() -> void:
	call_deferred("_check_wave_clear")

func _check_wave_clear() -> void:
	if not match_started or wave_transition:
		return
	if get_tree().get_nodes_in_group("enemies").is_empty():
		wave_transition = true
		current_wave += 1
		await get_tree().create_timer(2.0).timeout
		if is_instance_valid(player) and player.health > 0:
			_spawn_wave(current_wave)

func player_died() -> void:
	if not match_started:
		return
	match_started = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().create_timer(2.0).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()

func return_to_menu() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()

func _build_atmosphere() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var material := ProceduralSkyMaterial.new()
	material.sky_top_color = Color(0.16, 0.34, 0.55)
	material.sky_horizon_color = Color(0.48, 0.61, 0.68)
	material.ground_bottom_color = Color(0.12, 0.14, 0.15)
	material.ground_horizon_color = Color(0.38, 0.43, 0.45)
	sky.sky_material = material
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.52, 0.56, 0.60)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_color = Color(0.82, 0.86, 0.91)
	sun.light_energy = 0.72
	sun.shadow_enabled = false
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
		_add_static_box_emissive(Vector3(x, 4, 0), Vector3(0.22, 8, 0.22), Color(0.92, 0.98, 1.0), 2.8)
		_add_static_box_emissive(Vector3(x, 7.8, 0), Vector3(5, 0.22, 0.22), Color(0.92, 0.98, 1.0), 2.8)

func _build_map_details() -> void:
	# Industrial lanes, container stacks and concrete dividers create readable combat routes.
	_add_static_box(Vector3(-27, 1.25, -5), Vector3(8, 2.5, 3.2), Color(0.16, 0.19, 0.20))
	_add_static_box(Vector3(-27, 3.85, -5), Vector3(8, 2.5, 3.2), Color(0.19, 0.21, 0.21))
	_add_static_box(Vector3(27, 1.25, 6), Vector3(8, 2.5, 3.2), Color(0.17, 0.19, 0.20))
	_add_static_box(Vector3(7, 1.0, -29), Vector3(12, 2.0, 2.0), Color(0.22, 0.23, 0.21))
	_add_static_box(Vector3(-7, 1.0, 29), Vector3(12, 2.0, 2.0), Color(0.22, 0.23, 0.21))
	# Short concrete barriers break up long sight lines without closing the arena.
	for x in [-18.0, 18.0]:
		for z in [-18.0, 18.0]:
			_add_static_box(Vector3(x, 0.65, z), Vector3(4.0, 1.3, 1.1), Color(0.30, 0.31, 0.29))
	# Industrial light poles and cool daylight fill.
	for pos in [Vector3(-34, 0, -34), Vector3(34, 0, -34), Vector3(-34, 0, 34), Vector3(34, 0, 34)]:
		_add_static_box(pos + Vector3(0, 4.0, 0), Vector3(0.28, 8.0, 0.28), Color(0.085, 0.095, 0.095))
		_add_static_box_emissive(pos + Vector3(0, 8.1, 0), Vector3(1.2, 0.18, 0.55), Color(0.88, 0.96, 1.0), 1.5)
		# Emissive fixtures provide the industrial look without costly per-pixel point lights.
	# Painted lane markings and restrained hazard blocks are visual-only.
	for z in [-31.0, 31.0]:
		for x in range(-24, 25, 6):
			var stripe := MeshInstance3D.new()
			var stripe_mesh := BoxMesh.new()
			stripe_mesh.size = Vector3(2.2, 0.025, 0.16)
			stripe.mesh = stripe_mesh
			stripe.position = Vector3(float(x), 0.015, z)
			stripe.material_override = _material(Color(0.43, 0.39, 0.25), 0.0, 0.95)
			add_child(stripe)

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

func _add_static_box_emissive(pos: Vector3, size: Vector3, color: Color, energy: float) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	add_child(body)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = energy
	mesh.material_override = mat
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

