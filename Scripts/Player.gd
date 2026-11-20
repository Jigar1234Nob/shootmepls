extends CharacterBody3D
class_name FPSPlayer

@export var walk_speed := 7.0
@export var sprint_speed := 10.0
@export var jump_velocity := 5.5
@export var mouse_sensitivity := 0.0022
@export var fire_rate := 0.09

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_pivot: Node3D
var camera: Camera3D
var gun_visual: Node3D
var pitch := 0.0
var max_health := 100.0
var health := 100.0
var ammo := 90
var fire_cooldown := 0.0
var mobile_move := Vector2.ZERO
var mobile_fire := false
var mobile_jump := false
var controller_aim_sensitivity := 2.3
var controller_deadzone := 0.16
var controller_jump_button := JOY_BUTTON_A
var controller_fire_button := JOY_BUTTON_RIGHT_SHOULDER
var controller_fire_alt_button := JOY_BUTTON_X
var controller_sprint_button := JOY_BUTTON_LEFT_STICK
var controller_pause_button := JOY_BUTTON_START
var _controller_jump_was_down := false
var settings_panel: VBoxContainer
var pause_menu_box: VBoxContainer
var rebind_prompt: Label
var waiting_for_bind := ""
var waiting_for_controller_bind := ""
var keybind_buttons: Dictionary = {}
var controller_bind_buttons: Dictionary = {}
var hud: Label
var health_bar: ColorRect
var health_fill: ColorRect
var ammo_label: Label
var pause_layer: Control
var paused := false
var bob_time := 0.0
var gun_home := Vector3(0.34, -0.27, -0.62)
var damage_flash: ColorRect

func _ready() -> void:
	_load_settings()
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("player")
	_make_collision()
	_make_shadow()
	_make_camera()
	_make_gun()
	_make_hud()
	if not OS.has_feature("mobile"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _make_collision() -> void:
	var col := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.48
	capsule.height = 1.8
	col.shape = capsule
	col.position.y = 0.9
	add_child(col)

func _make_shadow() -> void:
	var shadow := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.62
	mesh.height = 0.04
	shadow.mesh = mesh
	shadow.position.y = -0.47
	shadow.scale = Vector3(1.0, 0.05, 1.35)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.015, 0.035, 0.018, 0.48)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow.material_override = mat
	add_child(shadow)

func _make_camera() -> void:
	camera_pivot = Node3D.new()
	camera_pivot.position.y = 1.48
	add_child(camera_pivot)
	camera = Camera3D.new()
	camera.fov = 82
	camera.current = true
	camera_pivot.add_child(camera)

func _make_gun() -> void:
	gun_visual = Node3D.new()
	gun_visual.position = gun_home
	camera.add_child(gun_visual)
	# Procedural compact rifle model with stock, receiver, barrel, magazine and sights.
	var steel := Color(0.075, 0.082, 0.078)
	var polymer := Color(0.035, 0.040, 0.038)
	var edge := Color(0.13, 0.14, 0.13)
	_add_box(Vector3(0, -0.015, -0.02), Vector3(0.20, 0.17, 0.43), steel)
	_add_box(Vector3(0, 0.005, -0.34), Vector3(0.105, 0.105, 0.48), polymer)
	_add_box(Vector3(0, -0.015, -0.64), Vector3(0.075, 0.075, 0.22), steel)
	_add_box(Vector3(0, -0.13, 0.12), Vector3(0.16, 0.13, 0.30), polymer)
	_add_box(Vector3(0, -0.18, -0.03), Vector3(0.115, 0.25, 0.15), polymer)
	_add_box(Vector3(0, 0.105, -0.27), Vector3(0.13, 0.055, 0.24), edge)
	_add_box(Vector3(0, 0.15, -0.27), Vector3(0.085, 0.045, 0.14), polymer)
	_add_box(Vector3(0, 0.115, -0.02), Vector3(0.035, 0.045, 0.075), edge)
	_add_box(Vector3(0, 0.095, -0.59), Vector3(0.025, 0.055, 0.045), edge)
	_add_box(Vector3(0, -0.105, -0.24), Vector3(0.105, 0.23, 0.16), polymer)

func _add_box(pos: Vector3, size: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	part.mesh = box
	part.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.42
	mat.roughness = 0.32
	part.material_override = mat
	gun_visual.add_child(part)

func _make_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var top_panel := PanelContainer.new()
	top_panel.position = Vector2(22, 20)
	top_panel.custom_minimum_size = Vector2(260, 82)
	top_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.03, 0.028, 0.92), Color(0.34, 0.35, 0.31, 0.8)))
	root.add_child(top_panel)
	var stats := VBoxContainer.new()
	stats.add_theme_constant_override("separation", 7)
	top_panel.add_child(stats)
	var health_title := Label.new()
	health_title.text = "VITALS"
	health_title.add_theme_color_override("font_color", Color(0.66, 0.67, 0.60))
	health_title.add_theme_font_size_override("font_size", 12)
	stats.add_child(health_title)
	hud = Label.new()
	hud.add_theme_font_size_override("font_size", 17)
	hud.add_theme_color_override("font_color", Color.WHITE)
	stats.add_child(hud)
	health_bar = ColorRect.new()
	health_bar.custom_minimum_size = Vector2(220, 7)
	health_bar.color = Color(0.12, 0.17, 0.22)
	stats.add_child(health_bar)
	health_fill = ColorRect.new()
	health_fill.color = Color(0.58, 0.61, 0.43)
	health_fill.size = Vector2(220, 7)
	health_bar.add_child(health_fill)

	var ammo_panel := PanelContainer.new()
	ammo_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	ammo_panel.position = Vector2(-220, -92)
	ammo_panel.custom_minimum_size = Vector2(195, 70)
	ammo_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.03, 0.028, 0.94), Color(0.34, 0.35, 0.31, 0.8)))
	root.add_child(ammo_panel)
	ammo_label = Label.new()
	ammo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ammo_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ammo_label.add_theme_font_size_override("font_size", 25)
	ammo_label.add_theme_color_override("font_color", Color(0.84, 0.84, 0.78))
	ammo_panel.add_child(ammo_label)

	var cross := Label.new()
	cross.text = "＋"
	cross.add_theme_font_size_override("font_size", 25)
	cross.add_theme_color_override("font_color", Color(0.82, 0.83, 0.76, 0.92))
	cross.set_anchors_preset(Control.PRESET_CENTER)
	cross.position = Vector2(-10, -19)
	root.add_child(cross)

	damage_flash = ColorRect.new()
	damage_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	damage_flash.color = Color(0.9, 0.08, 0.08, 0)
	damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(damage_flash)

	var pause_button := Button.new()
	pause_button.text = "Ⅱ"
	pause_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause_button.position = Vector2(-76, 20)
	pause_button.custom_minimum_size = Vector2(54, 48)
	pause_button.pressed.connect(_toggle_pause)
	root.add_child(pause_button)
	if OS.has_feature("mobile"):
		_add_touch_controls(root)
	_make_pause_menu(layer)
	_update_hud()

func _panel_style(fill: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func _add_touch_controls(root: Control) -> void:
	var stick := Control.new()
	stick.position = Vector2(20, -180)
	stick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	stick.custom_minimum_size = Vector2(170, 160)
	stick.mouse_filter = Control.MOUSE_FILTER_STOP
	stick.draw.connect(func():
		stick.draw_circle(Vector2(85, 80), 72, Color(0.025, 0.03, 0.028, 0.62))
		stick.draw_arc(Vector2(85, 80), 72, 0, TAU, 48, Color(0.52, 0.55, 0.49, 0.5), 2)
		stick.draw_circle(Vector2(85 + mobile_move.x * 45, 80 + mobile_move.y * 45), 28, Color(0.52, 0.55, 0.46, 0.72))
	)
	stick.gui_input.connect(func(event):
		if event is InputEventScreenTouch:
			if not event.pressed:
				mobile_move = Vector2.ZERO
			else:
				mobile_move = ((event.position - Vector2(85, 80)) / 65.0).limit_length(1.0)
			stick.queue_redraw()
		elif event is InputEventScreenDrag:
			mobile_move = ((event.position - Vector2(85, 80)) / 65.0).limit_length(1.0)
			stick.queue_redraw()
	)
	root.add_child(stick)

	var fire := Button.new()
	fire.text = "FIRE"
	fire.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	fire.position = Vector2(-150, -165)
	fire.custom_minimum_size = Vector2(122, 92)
	fire.add_theme_font_size_override("font_size", 20)
	fire.button_down.connect(func(): mobile_fire = true)
	fire.button_up.connect(func(): mobile_fire = false)
	root.add_child(fire)

	var jump := Button.new()
	jump.text = "JUMP"
	jump.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	jump.position = Vector2(-150, -62)
	jump.custom_minimum_size = Vector2(112, 48)
	jump.button_down.connect(func(): mobile_jump = true)
	jump.button_up.connect(func(): mobile_jump = false)
	root.add_child(jump)

func _make_pause_menu(layer: CanvasLayer) -> void:
	pause_layer = Control.new()
	pause_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_layer.visible = false
	pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(pause_layer)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.008, 0.018, 0.035, 0.82)
	pause_layer.add_child(shade)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 560)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-310, -280)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.03, 0.028, 0.98), Color(0.42, 0.43, 0.37)))
	pause_layer.add_child(panel)
	var root_column := VBoxContainer.new()
	root_column.add_theme_constant_override("separation", 14)
	panel.add_child(root_column)

	pause_menu_box = VBoxContainer.new()
	pause_menu_box.add_theme_constant_override("separation", 12)
	root_column.add_child(pause_menu_box)
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color(0.82, 0.83, 0.76))
	pause_menu_box.add_child(title)
	var hint := Label.new()
	hint.text = "MATCH PAUSED  /  OPERATIONS MENU"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.62, 0.63, 0.57))
	pause_menu_box.add_child(hint)
	var resume := Button.new()
	resume.text = "RESUME  ·  ESC"
	resume.pressed.connect(_toggle_pause)
	pause_menu_box.add_child(resume)
	var settings_button := Button.new()
	settings_button.text = "SETTINGS"
	settings_button.pressed.connect(_show_settings)
	pause_menu_box.add_child(settings_button)
	var restart := Button.new()
	restart.text = "RESTART MATCH"
	restart.pressed.connect(func(): get_tree().paused = false; get_tree().reload_current_scene())
	pause_menu_box.add_child(restart)
	var quit := Button.new()
	quit.text = "QUIT"
	quit.pressed.connect(func(): get_tree().quit())
	pause_menu_box.add_child(quit)

	settings_panel = VBoxContainer.new()
	settings_panel.visible = false
	settings_panel.add_theme_constant_override("separation", 10)
	root_column.add_child(settings_panel)
	var settings_title := Label.new()
	settings_title.text = "SETTINGS"
	settings_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_title.add_theme_font_size_override("font_size", 24)
	settings_title.add_theme_color_override("font_color", Color(0.82, 0.83, 0.76))
	settings_panel.add_child(settings_title)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(570, 405)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	settings_panel.add_child(scroll)
	var settings_rows := VBoxContainer.new()
	settings_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_rows.add_theme_constant_override("separation", 8)
	scroll.add_child(settings_rows)

	_add_settings_section(settings_rows, "AIM")
	_add_slider_setting(settings_rows, "Mouse sensitivity", 0.0005, 0.01, mouse_sensitivity, 0.0001, _set_mouse_sensitivity)
	_add_slider_setting(settings_rows, "Controller look sensitivity", 0.5, 8.0, controller_aim_sensitivity, 0.1, _set_controller_sensitivity)
	_add_slider_setting(settings_rows, "Controller stick deadzone", 0.05, 0.4, controller_deadzone, 0.01, _set_controller_deadzone)

	_add_settings_section(settings_rows, "KEYBOARD / MOUSE BINDS")
	_add_rebind_row(settings_rows, "Move forward", "move_forward")
	_add_rebind_row(settings_rows, "Move backward", "move_backward")
	_add_rebind_row(settings_rows, "Move left", "move_left")
	_add_rebind_row(settings_rows, "Move right", "move_right")
	_add_rebind_row(settings_rows, "Jump", "jump")
	_add_rebind_row(settings_rows, "Sprint", "sprint")
	_add_rebind_row(settings_rows, "Fire", "fire")

	_add_settings_section(settings_rows, "CONTROLLER BINDS")
	_add_controller_rebind_row(settings_rows, "Jump", "jump")
	_add_controller_rebind_row(settings_rows, "Fire", "fire")
	_add_controller_rebind_row(settings_rows, "Alternate fire", "fire_alt")
	_add_controller_rebind_row(settings_rows, "Sprint", "sprint")
	_add_controller_rebind_row(settings_rows, "Pause", "pause")
	rebind_prompt = Label.new()
	rebind_prompt.text = "Select a bind to change it."
	rebind_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rebind_prompt.add_theme_color_override("font_color", Color(0.68, 0.69, 0.62))
	settings_panel.add_child(rebind_prompt)
	var settings_footer := HBoxContainer.new()
	settings_panel.add_child(settings_footer)
	var back := Button.new()
	back.text = "BACK"
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back.pressed.connect(_hide_settings)
	settings_footer.add_child(back)
	var reset := Button.new()
	reset.text = "RESET DEFAULTS"
	reset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset.pressed.connect(_reset_settings)
	settings_footer.add_child(reset)

func _toggle_pause() -> void:
	paused = not paused
	get_tree().paused = paused
	pause_layer.visible = paused
	if OS.has_feature("mobile"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_toggle_pause()
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed and event.button_index == controller_pause_button:
		_toggle_pause()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if not paused:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
		elif event.button_index == MOUSE_BUTTON_LEFT and not paused and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and not OS.has_feature("mobile"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not paused:
		_aim(event.relative)
	elif event is InputEventScreenDrag and event.position.x > get_viewport().get_visible_rect().size.x * 0.38:
		_aim(event.relative)

func _get_controller_device() -> int:
	var devices := Input.get_connected_joypads()
	return devices[0] if not devices.is_empty() else -1

func _aim(delta: Vector2) -> void:
	rotate_y(-delta.x * mouse_sensitivity)
	pitch = clamp(pitch - delta.y * mouse_sensitivity, -1.35, 1.35)
	camera_pivot.rotation.x = pitch

func _physics_process(delta: float) -> void:
	if paused:
		return
	var controller := _get_controller_device()
	if controller >= 0:
		var right_x := Input.get_joy_axis(controller, JOY_AXIS_RIGHT_X)
		var right_y := Input.get_joy_axis(controller, JOY_AXIS_RIGHT_Y)
		if absf(right_x) > controller_deadzone or absf(right_y) > controller_deadzone:
			_aim(Vector2(right_x, right_y) * controller_aim_sensitivity * delta * 60.0)
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	var controller_fire := controller >= 0 and (Input.is_joy_button_pressed(controller, controller_fire_button) or Input.is_joy_button_pressed(controller, controller_fire_alt_button))
	if (Input.is_action_pressed("fire") or mobile_fire or controller_fire) and fire_cooldown <= 0:
		_fire()
		fire_cooldown = fire_rate
	if not is_on_floor():
		velocity.y -= gravity * delta
	var controller_jump := controller >= 0 and Input.is_joy_button_pressed(controller, controller_jump_button)
	if (Input.is_action_just_pressed("jump") or mobile_jump or (controller_jump and not _controller_jump_was_down)) and is_on_floor():
		velocity.y = jump_velocity
	_controller_jump_was_down = controller_jump
	var move := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if controller >= 0:
		var left_stick := Vector2(Input.get_joy_axis(controller, JOY_AXIS_LEFT_X), Input.get_joy_axis(controller, JOY_AXIS_LEFT_Y))
		if left_stick.length() > controller_deadzone:
			move = left_stick.limit_length(1.0)
	if mobile_move.length() > 0.08:
		move = mobile_move
	var direction := (transform.basis * Vector3(move.x, 0, move.y)).normalized()
	var moving := direction.length() > 0.05
	var controller_sprint := controller >= 0 and Input.is_joy_button_pressed(controller, controller_sprint_button)
	var speed := sprint_speed if (Input.is_action_pressed("sprint") or controller_sprint) and not OS.has_feature("mobile") else walk_speed
	velocity.x = direction.x * speed if moving else move_toward(velocity.x, 0.0, walk_speed * 8 * delta)
	velocity.z = direction.z * speed if moving else move_toward(velocity.z, 0.0, walk_speed * 8 * delta)
	move_and_slide()
	if moving and is_on_floor():
		bob_time += delta * 10.0
	else:
		bob_time = move_toward(bob_time, 0.0, delta * 5.0)
	if is_instance_valid(gun_visual):
		gun_visual.position = gun_home + Vector3(0, sin(bob_time) * 0.012, absf(cos(bob_time)) * 0.012)

func _fire() -> void:
	if ammo <= 0:
		return
	ammo -= 1
	_update_hud()
	var bullet = preload("res://Scripts/Bullet.gd").new()
	bullet.direction = -camera.global_transform.basis.z
	bullet.global_position = camera.global_position + bullet.direction * 0.85
	get_tree().current_scene.add_child(bullet)

func take_damage(amount: float) -> void:
	health = maxf(0, health - amount)
	_update_hud()
	if is_instance_valid(damage_flash):
		damage_flash.color = Color(0.9, 0.08, 0.08, 0.22)
		var tween := create_tween()
		tween.tween_property(damage_flash, "color:a", 0.0, 0.28)
	if health <= 0:
		paused = true
		get_tree().paused = true
		pause_layer.visible = true

func heal(amount: float) -> void:
	health = minf(max_health, health + amount)
	_update_hud()

func add_ammo(amount: int) -> void:
	ammo += amount
	_update_hud()

func _update_hud() -> void:
	if is_instance_valid(hud):
		hud.text = "HEALTH   %d%%" % int(health)
	if is_instance_valid(health_fill):
		health_fill.size.x = 220.0 * (health / max_health)
		health_fill.color = Color(0.58, 0.61, 0.43) if health > 35 else Color(0.68, 0.39, 0.27)
	if is_instance_valid(ammo_label):
		ammo_label.text = "AMMO   %03d" % ammo

func _show_settings() -> void:
	waiting_for_bind = ""
	waiting_for_controller_bind = ""
	pause_menu_box.visible = false
	settings_panel.visible = true
	_refresh_bind_labels()

func _hide_settings() -> void:
	waiting_for_bind = ""
	waiting_for_controller_bind = ""
	settings_panel.visible = false
	pause_menu_box.visible = true

func _add_settings_section(parent: VBoxContainer, text_value: String) -> void:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.67, 0.69, 0.61))
	parent.add_child(label)
	var line := HSeparator.new()
	parent.add_child(line)

func _add_slider_setting(parent: VBoxContainer, label_text: String, min_value: float, max_value: float, initial: float, step: float, callback: Callable) -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	parent.add_child(row)
	var heading := HBoxContainer.new()
	row.add_child(heading)
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(label)
	var value_label := Label.new()
	value_label.text = "%.4f" % initial if step < 0.001 else "%.1f" % initial
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	heading.add_child(value_label)
	var slider := HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = initial
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(func(value: float):
		callback.call(value)
		value_label.text = "%.4f" % value if step < 0.001 else "%.1f" % value
	)
	row.add_child(slider)

func _set_mouse_sensitivity(value: float) -> void:
	mouse_sensitivity = value
	_save_settings()

func _set_controller_sensitivity(value: float) -> void:
	controller_aim_sensitivity = value
	_save_settings()

func _set_controller_deadzone(value: float) -> void:
	controller_deadzone = value
	_save_settings()

func _add_rebind_row(parent: VBoxContainer, label_text: String, action: String) -> void:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var button := Button.new()
	button.custom_minimum_size.x = 150
	button.text = _get_action_binding_text(action)
	button.pressed.connect(func(): _begin_key_rebind(action))
	row.add_child(button)
	keybind_buttons[action] = button

func _add_controller_rebind_row(parent: VBoxContainer, label_text: String, action: String) -> void:
	var row := HBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var button := Button.new()
	button.custom_minimum_size.x = 150
	button.text = _get_controller_binding_text(action)
	button.pressed.connect(func(): _begin_controller_rebind(action))
	row.add_child(button)
	controller_bind_buttons[action] = button

func _get_action_binding_text(action: String) -> String:
	var events := InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode if event.physical_keycode != 0 else event.keycode)
		if event is InputEventMouseButton:
			return "Mouse %d" % event.button_index
	return "Unbound"

func _get_controller_binding_text(action: String) -> String:
	var button_index := JOY_BUTTON_A
	match action:
		"jump": button_index = controller_jump_button
		"fire": button_index = controller_fire_button
		"fire_alt": button_index = controller_fire_alt_button
		"sprint": button_index = controller_sprint_button
		"pause": button_index = controller_pause_button
	return _joy_button_name(button_index)

func _joy_button_name(button_index: int) -> String:
	var names := {
		JOY_BUTTON_A: "A / Cross", JOY_BUTTON_B: "B / Circle",
		JOY_BUTTON_X: "X / Square", JOY_BUTTON_Y: "Y / Triangle",
		JOY_BUTTON_LEFT_SHOULDER: "LB / L1", JOY_BUTTON_RIGHT_SHOULDER: "RB / R1",
		JOY_BUTTON_BACK: "Back / Share", JOY_BUTTON_START: "Start / Options",
		JOY_BUTTON_LEFT_STICK: "L3", JOY_BUTTON_RIGHT_STICK: "R3",
		JOY_BUTTON_DPAD_UP: "D-pad Up", JOY_BUTTON_DPAD_DOWN: "D-pad Down",
		JOY_BUTTON_DPAD_LEFT: "D-pad Left", JOY_BUTTON_DPAD_RIGHT: "D-pad Right"
	}
	return names.get(button_index, "Button %d" % button_index)

func _begin_key_rebind(action: String) -> void:
	waiting_for_bind = action
	waiting_for_controller_bind = ""
	rebind_prompt.text = "Press a key or mouse button for %s. ESC cancels." % action.replace("_", " ").to_upper()
	_refresh_bind_labels()

func _begin_controller_rebind(action: String) -> void:
	waiting_for_controller_bind = action
	waiting_for_bind = ""
	rebind_prompt.text = "Press a controller button for %s. ESC cancels." % action.to_upper()
	_refresh_bind_labels()

func _refresh_bind_labels() -> void:
	for action in keybind_buttons:
		var button: Button = keybind_buttons[action]
		button.text = "PRESS KEY..." if waiting_for_bind == action else _get_action_binding_text(action)
	for action in controller_bind_buttons:
		var button: Button = controller_bind_buttons[action]
		button.text = "PRESS BUTTON..." if waiting_for_controller_bind == action else _get_controller_binding_text(action)

func _input(event: InputEvent) -> void:
	if waiting_for_bind != "":
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE:
				waiting_for_bind = ""
				rebind_prompt.text = "Binding cancelled."
			else:
				var action := waiting_for_bind
				InputMap.action_erase_events(action)
				var new_event := event.duplicate() as InputEventKey
				new_event.echo = false
				InputMap.action_add_event(action, new_event)
				waiting_for_bind = ""
				_save_settings()
				rebind_prompt.text = "Updated %s." % action
			_refresh_bind_labels()
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.pressed:
			var mouse_action := waiting_for_bind
			InputMap.action_erase_events(mouse_action)
			InputMap.action_add_event(mouse_action, event.duplicate())
			waiting_for_bind = ""
			_save_settings()
			rebind_prompt.text = "Updated %s." % mouse_action
			_refresh_bind_labels()
			get_viewport().set_input_as_handled()
	elif waiting_for_controller_bind != "" and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		waiting_for_controller_bind = ""
		rebind_prompt.text = "Binding cancelled."
		_refresh_bind_labels()
		get_viewport().set_input_as_handled()
	elif waiting_for_controller_bind != "" and event is InputEventJoypadButton and event.pressed:
		_set_controller_binding(waiting_for_controller_bind, event.button_index)
		var changed := waiting_for_controller_bind
		waiting_for_controller_bind = ""
		rebind_prompt.text = "Updated controller %s." % changed
		_refresh_bind_labels()
		get_viewport().set_input_as_handled()

func _set_controller_binding(action: String, button_index: int) -> void:
	match action:
		"jump": controller_jump_button = button_index
		"fire": controller_fire_button = button_index
		"fire_alt": controller_fire_alt_button = button_index
		"sprint": controller_sprint_button = button_index
		"pause": controller_pause_button = button_index
	_save_settings()

func _reset_settings() -> void:
	mouse_sensitivity = 0.0022
	controller_aim_sensitivity = 2.3
	controller_deadzone = 0.16
	controller_jump_button = JOY_BUTTON_A
	controller_fire_button = JOY_BUTTON_RIGHT_SHOULDER
	controller_fire_alt_button = JOY_BUTTON_X
	controller_sprint_button = JOY_BUTTON_LEFT_STICK
	controller_pause_button = JOY_BUTTON_START
	var defaults := {
		"move_forward": KEY_W, "move_backward": KEY_S,
		"move_left": KEY_A, "move_right": KEY_D,
		"jump": KEY_SPACE, "sprint": KEY_SHIFT
	}
	for action in defaults:
		InputMap.action_erase_events(action)
		var key_event := InputEventKey.new()
		key_event.physical_keycode = defaults[action]
		InputMap.action_add_event(action, key_event)
	InputMap.action_erase_events("fire")
	var mouse_event := InputEventMouseButton.new()
	mouse_event.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("fire", mouse_event)
	_save_settings()
	_show_settings()
	rebind_prompt.text = "Settings restored to defaults."

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") != OK:
		return
	mouse_sensitivity = float(config.get_value("aim", "mouse_sensitivity", mouse_sensitivity))
	controller_aim_sensitivity = float(config.get_value("aim", "controller_sensitivity", controller_aim_sensitivity))
	controller_deadzone = float(config.get_value("aim", "controller_deadzone", controller_deadzone))
	controller_jump_button = int(config.get_value("controller", "jump", controller_jump_button))
	controller_fire_button = int(config.get_value("controller", "fire", controller_fire_button))
	controller_fire_alt_button = int(config.get_value("controller", "fire_alt", controller_fire_alt_button))
	controller_sprint_button = int(config.get_value("controller", "sprint", controller_sprint_button))
	controller_pause_button = int(config.get_value("controller", "pause", controller_pause_button))
	for action in ["move_forward", "move_backward", "move_left", "move_right", "jump", "sprint", "fire"]:
		var saved = config.get_value("keybinds", action, {})
		if typeof(saved) != TYPE_DICTIONARY:
			continue
		InputMap.action_erase_events(action)
		if saved.get("type", "") == "key":
			var key_event := InputEventKey.new()
			key_event.physical_keycode = int(saved.get("physical_keycode", 0))
			key_event.keycode = int(saved.get("keycode", 0))
			InputMap.action_add_event(action, key_event)
		elif saved.get("type", "") == "mouse":
			var mouse_event := InputEventMouseButton.new()
			mouse_event.button_index = int(saved.get("button_index", MOUSE_BUTTON_LEFT))
			InputMap.action_add_event(action, mouse_event)

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("aim", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("aim", "controller_sensitivity", controller_aim_sensitivity)
	config.set_value("aim", "controller_deadzone", controller_deadzone)
	config.set_value("controller", "jump", controller_jump_button)
	config.set_value("controller", "fire", controller_fire_button)
	config.set_value("controller", "fire_alt", controller_fire_alt_button)
	config.set_value("controller", "sprint", controller_sprint_button)
	config.set_value("controller", "pause", controller_pause_button)
	for action in ["move_forward", "move_backward", "move_left", "move_right", "jump", "sprint", "fire"]:
		var saved := {}
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				saved = {"type": "key", "physical_keycode": event.physical_keycode, "keycode": event.keycode}
				break
			elif event is InputEventMouseButton:
				saved = {"type": "mouse", "button_index": event.button_index}
				break
		config.set_value("keybinds", action, saved)
	config.save("user://settings.cfg")
