extends Node3D
var player: CharacterBody3D
var main_menu: Control
var menu_status: Label
var match_started := false

func _ready() -> void:
	_build_atmosphere()
	_show_start_screen()

func _show_start_screen() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	main_menu = Control.new()
	main_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(main_menu)

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
	menu_status.text = "WASD MOVE  /  MOUSE AIM  /  LEFT CLICK FIRE  /  SPACE JUMP  /  SHIFT SPRINT  /  ESC PAUSE"

func _start_match() -> void:
	if match_started:
		return
	match_started = true
	main_menu.queue_free()
	_build_floor()
	_build_perimeter()
	_build_cover()
	_spawn_enemies()
	_spawn_pickups()
	player = preload("res://Scripts/Player.gd").new()
	add_child(player)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
