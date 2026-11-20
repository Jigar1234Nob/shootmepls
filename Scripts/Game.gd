extends Node3D

const PLAYER_SCENE_SCRIPT = preload("res://Scripts/Player.gd")
const BEAN_SCRIPT = preload("res://Scripts/BeanEnemy.gd")
const PICKUP_SCRIPT = preload("res://Scripts/Pickup.gd")

var player: FPSPlayer
var enemies: Array[BeanEnemy] = []
var cash := 0
var kills := 0
var wave := 0
var spawn_timer := 0.0
var game_started := false
var game_over := false
var shop_open := false
var hud_layer: CanvasLayer
var menu_panel: Panel
var shop_panel: Panel
var game_over_panel: Panel
var health_label: Label
var ammo_label: Label
var cash_label: Label
var wave_label: Label
var kills_label: Label
var message_label: Label
var health_bar: ProgressBar
var damage_upgrade_cost := 180
var fire_upgrade_cost := 220

func _ready() -> void:
	randomize()
	_build_world()
	_build_ui()
	_show_menu()

func _process(delta: float) -> void:
	if not game_started or game_over:
		return
	spawn_timer -= delta
	if spawn_timer <= 0.0 and enemies.size() < mini(5 + wave * 2, 18):
		_spawn_bean()
		spawn_timer = maxf(0.8, 3.2 - wave * 0.12)
	if Input.is_key_pressed(KEY_B) and not shop_open:
		_open_shop()
	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B and game_started and not game_over:
			if shop_open:
				_close_shop()
			else:
				_open_shop()
		if event.keycode == KEY_ESCAPE and shop_open:
			_close_shop()

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.38, 0.44, 0.58)
	environment.ambient_light_energy = 0.65
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = environment
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)
	_make_box("ArenaFloor", Vector3(0, -0.5, 0), Vector3(48, 1, 48), Color(0.19, 0.22, 0.25), true)
	_make_box("NorthWall", Vector3(0, 2.0, -24), Vector3(48, 4, 1), Color(0.12, 0.16, 0.21), true)
	_make_box("SouthWall", Vector3(0, 2.0, 24), Vector3(48, 4, 1), Color(0.12, 0.16, 0.21), true)
	_make_box("EastWall", Vector3(24, 2.0, 0), Vector3(1, 4, 48), Color(0.12, 0.16, 0.21), true)
	_make_box("WestWall", Vector3(-24, 2.0, 0), Vector3(1, 4, 48), Color(0.12, 0.16, 0.21), true)
	for i in range(12):
		var x := randf_range(-19, 19)
		var z := randf_range(-19, 19)
		if Vector2(x, z).length() < 6:
			x += 9
		_make_box("Cover_%02d" % i, Vector3(x, 0.65, z), Vector3(randf_range(1.3, 2.8), 1.3, randf_range(1.2, 2.2)), Color(0.28, 0.32, 0.37), true)
	for i in range(8):
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(randf_range(-18, 18), 4.5, randf_range(-18, 18))
		lamp.light_color = Color(0.35, 0.62, 1.0)
		lamp.light_energy = 1.4
		lamp.omni_range = 8
		add_child(lamp)

func _make_box(node_name: String, pos: Vector3, size: Vector3, color: Color, solid: bool) -> void:
	var parent: Node3D = self
	if solid:
		var body := StaticBody3D.new()
		body.name = node_name
		body.position = pos
		add_child(body)
		parent = body
	else:
		var holder := Node3D.new()
		holder.name = node_name
		holder.position = pos
		add_child(holder)
		parent = holder
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.82
	mat.metallic = 0.18
	mesh.material_override = mat
	parent.add_child(mesh)
	if solid:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		parent.add_child(collision)

func _build_ui() -> void:
	hud_layer = CanvasLayer.new()
	add_child(hud_layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_layer.add_child(root)
	health_label = _label(root, "HEALTH 100", Vector2(28, 22), 22, Color(0.45, 1, 0.65))
	ammo_label = _label(root, "12 / 60", Vector2(1050, 625), 26, Color.WHITE)
	cash_label = _label(root, "$0", Vector2(28, 55), 22, Color(1, 0.82, 0.25))
	wave_label = _label(root, "WAVE 1", Vector2(28, 88), 18, Color(0.75, 0.85, 1))
	kills_label = _label(root, "KILLS 0", Vector2(28, 116), 18, Color.WHITE)
	message_label = _label(root, "B: WEAPON SHOP", Vector2(500, 670), 16, Color(0.8, 0.86, 1))
	message_label.size = Vector2(280, 30)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	health_bar = ProgressBar.new()
	health_bar.position = Vector2(28, 150)
	health_bar.size = Vector2(240, 18)
	health_bar.max_value = 100
	health_bar.show_percentage = false
	root.add_child(health_bar)
	var cross := _label(root, "+", Vector2(627, 333), 28, Color.WHITE)
	cross.size = Vector2(28, 35)
	cross.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_panel = _panel(root, Vector2(0.5, 0.5), Vector2(520, 440))
	shop_panel = _panel(root, Vector2(0.5, 0.5), Vector2(620, 500))
	game_over_panel = _panel(root, Vector2(0.5, 0.5), Vector2(460, 300))
	_build_menu_contents()
	_build_shop_contents()
	_build_game_over_contents()

func _panel(parent: Control, center: Vector2, panel_size: Vector2) -> Panel:
	var panel := Panel.new()
	panel.size = panel_size
	panel.position = Vector2(640, 360) - panel_size * 0.5
	panel.visible = false
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.05, 0.075, 0.96)
	style.border_color = Color(0.18, 0.55, 0.82)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left = 26
	style.content_margin_right = 26
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

func _label(parent: Control, text_value: String, pos: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.size = Vector2(350, 32)
	parent.add_child(label)
	return label

func _button(parent: Control, text_value: String, pos: Vector2, button_size: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.position = pos
	button.size = button_size
	button.add_theme_font_size_override("font_size", 19)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.24, 0.36)
	style.border_color = Color(0.22, 0.62, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(7)
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate()
	hover.bg_color = Color(0.12, 0.38, 0.55)
	button.add_theme_stylebox_override("hover", hover)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _build_menu_contents() -> void:
	_label(menu_panel, "SHOOT ME PLS", Vector2(48, 40), 42, Color(0.35, 0.78, 1))
	_label(menu_panel, "BEAN SURVIVAL PROTOCOL", Vector2(52, 96), 16, Color(0.72, 0.8, 0.9))
	_button(menu_panel, "PLAY", Vector2(110, 155), Vector2(250, 54), _start_game)
	_button(menu_panel, "WEAPON SHOP", Vector2(110, 220), Vector2(250, 48), _open_shop_from_menu)
	_button(menu_panel, "HOW TO PLAY", Vector2(110, 280), Vector2(250, 45), _show_help)
	_label(menu_panel, "WASD MOVE   SPACE JUMP   SHIFT SPRINT\nMOUSE AIM   LEFT CLICK FIRE   R RELOAD\nB SHOP   E PICK UP", Vector2(45, 345), 14, Color(0.7, 0.78, 0.88))

func _build_shop_contents() -> void:
	_label(shop_panel, "FIELD ARMOURY", Vector2(35, 25), 34, Color(0.35, 0.78, 1))
	_label(shop_panel, "Spend cash earned from bean eliminations.", Vector2(38, 72), 15, Color(0.72, 0.8, 0.9))
	_button(shop_panel, "Ammo refill  |  $45", Vector2(40, 125), Vector2(245, 52), func(): _buy("ammo"))
	_button(shop_panel, "Medkit +50  |  $60", Vector2(320, 125), Vector2(245, 52), func(): _buy("health"))
	_button(shop_panel, "Damage upgrade  |  $180", Vector2(40, 195), Vector2(245, 52), func(): _buy("damage"))
	_button(shop_panel, "Faster fire rate  |  $220", Vector2(320, 195), Vector2(245, 52), func(): _buy("fire"))
	_button(shop_panel, "Close shop  [B]", Vector2(170, 330), Vector2(245, 48), _close_shop)
	_label(shop_panel, "Pickups also spawn in the arena. Walk over them.", Vector2(50, 405), 14, Color(0.7, 0.8, 0.9))

func _build_game_over_contents() -> void:
	_label(game_over_panel, "YOU GOT BEANED", Vector2(45, 35), 34, Color(1, 0.42, 0.35))
	_label(game_over_panel, "The beans have won this round.", Vector2(48, 95), 17, Color.WHITE)
	_button(game_over_panel, "TRY AGAIN", Vector2(90, 165), Vector2(230, 52), _restart)

func _show_menu() -> void:
	menu_panel.visible = true
	shop_panel.visible = false
	game_over_panel.visible = false
	_set_hud_visible(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _start_game() -> void:
	menu_panel.visible = false
	game_over_panel.visible = false
	game_started = true
	game_over = false
	cash = 0
	kills = 0
	wave = 1
	spawn_timer = 0.2
	player = FPSPlayer.new()
	player.position = Vector3(0, 0.1, 0)
	add_child(player)
	player.health_changed.connect(_on_health_changed)
	player.ammo_changed.connect(_on_ammo_changed)
	player.died.connect(_on_player_died)
	_set_hud_visible(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for i in range(3):
		_spawn_bean()

func _spawn_bean() -> void:
	if player == null or not is_instance_valid(player):
		return
	var bean := BeanEnemy.new()
	var angle := randf() * TAU
	var distance := randf_range(12, 20)
	bean.position = Vector3(cos(angle) * distance, 0.1, sin(angle) * distance)
	bean.player = player
	bean.defeated.connect(_on_bean_defeated)
	add_child(bean)
	enemies.append(bean)

func _on_bean_defeated(reward: int) -> void:
	cash += reward
	kills += 1
	if kills % 8 == 0:
		wave += 1
	if randf() < 0.35:
		_spawn_pickup("ammo" if randf() < 0.65 else "health")
	_update_hud()

func _spawn_pickup(kind: String) -> void:
	var pickup := WorldPickup.new()
	pickup.pickup_type = kind
	pickup.amount = 30 if kind == "ammo" else 35
	pickup.position = Vector3(randf_range(-18, 18), 0.55, randf_range(-18, 18))
	add_child(pickup)

func _on_health_changed(value: int, maximum: int) -> void:
	health_label.text = "HEALTH %d / %d" % [value, maximum]
	health_bar.value = value
	health_bar.max_value = maximum

func _on_ammo_changed(clip: int, reserve: int) -> void:
	ammo_label.text = "%d / %d" % [clip, reserve]

func _on_player_died() -> void:
	game_over = true
	game_started = false
	game_over_panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _update_hud() -> void:
	if player == null:
		return
	cash_label.text = "$%d" % cash
	wave_label.text = "WAVE %d" % wave
	kills_label.text = "KILLS %d" % kills

func _set_hud_visible(value: bool) -> void:
	health_label.visible = value
	ammo_label.visible = value
	cash_label.visible = value
	wave_label.visible = value
	kills_label.visible = value
	message_label.visible = value
	health_bar.visible = value

func _open_shop_from_menu() -> void:
	_start_game()
	_open_shop()

func _open_shop() -> void:
	if not game_started:
		return
	shop_open = true
	shop_panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_shop() -> void:
	shop_open = false
	shop_panel.visible = false
	if game_started and not game_over:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _buy(item: String) -> void:
	match item:
		"ammo":
			if cash >= 45:
				cash -= 45
				player.add_ammo(60)
				_notify("Ammo restocked.")
		"health":
			if cash >= 60 and player.health < player.max_health:
				cash -= 60
				player.heal(50)
				_notify("Health restored.")
		"damage":
			if cash >= damage_upgrade_cost:
				cash -= damage_upgrade_cost
				player.upgrade_damage(10)
				damage_upgrade_cost += 120
				_notify("Weapon damage increased.")
		"fire":
			if cash >= fire_upgrade_cost:
				cash -= fire_upgrade_cost
				player.fire_delay = maxf(0.07, player.fire_delay - 0.025)
				fire_upgrade_cost += 150
				_notify("Fire rate improved.")
	_update_hud()

func _notify(text_value: String) -> void:
	message_label.text = text_value
	var timer := get_tree().create_timer(2.0)
	timer.timeout.connect(func(): message_label.text = "B: WEAPON SHOP")

func _show_help() -> void:
	message_label.text = "WASD MOVE | SPACE JUMP | SHIFT SPRINT | R RELOAD | B SHOP"
	menu_panel.visible = false
	var timer := get_tree().create_timer(4.0)
	timer.timeout.connect(func():
		if not game_started:
			menu_panel.visible = true
	)

func _restart() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	for pickup in get_tree().get_nodes_in_group("pickups"):
		pickup.queue_free()
	if player and is_instance_valid(player):
		player.queue_free()
	player = null
	enemies.clear()
	shop_open = false
	_start_game()
