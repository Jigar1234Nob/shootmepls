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
var _controller_jump_was_down := false
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
	panel.custom_minimum_size = Vector2(330, 250)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-165, -125)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.04, 0.035, 0.98), Color(0.42, 0.43, 0.37)))
	pause_layer.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	panel.add_child(column)
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color(0.82, 0.83, 0.76))
	column.add_child(title)
	var hint := Label.new()
	hint.text = "Take a breather. The beans won't."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.62, 0.63, 0.57))
	column.add_child(hint)
	var resume := Button.new()
	resume.text = "RESUME  ·  ESC"
	resume.pressed.connect(_toggle_pause)
	column.add_child(resume)
	var restart := Button.new()
	restart.text = "RESTART"
	restart.pressed.connect(func(): get_tree().paused = false; get_tree().reload_current_scene())
	column.add_child(restart)
	var quit := Button.new()
	quit.text = "QUIT"
	quit.pressed.connect(func(): get_tree().quit())
	column.add_child(quit)

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
	elif event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START:
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
	var controller_fire := controller >= 0 and (Input.is_joy_button_pressed(controller, JOY_BUTTON_RIGHT_SHOULDER) or Input.is_joy_button_pressed(controller, JOY_BUTTON_X))
	if (Input.is_action_pressed("fire") or mobile_fire or controller_fire) and fire_cooldown <= 0:
		_fire()
		fire_cooldown = fire_rate
	if not is_on_floor():
		velocity.y -= gravity * delta
	var controller_jump := controller >= 0 and Input.is_joy_button_pressed(controller, JOY_BUTTON_A)
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
	var controller_sprint := controller >= 0 and Input.is_joy_button_pressed(controller, JOY_BUTTON_LEFT_STICK)
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
