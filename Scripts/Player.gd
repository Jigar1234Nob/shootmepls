extends CharacterBody3D
class_name FPSPlayer

@export var walk_speed := 7.0
@export var jump_velocity := 5.5
@export var mouse_sensitivity := 0.0025
@export var fire_rate := 0.09
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_pivot: Node3D
var camera: Camera3D
var gun_visual: Node3D
var pitch := 0.0
var health := 100.0
var ammo := 90
var fire_cooldown := 0.0
var mobile_move := Vector2.ZERO
var mobile_fire := false
var mobile_jump := false
var hud: Label
var pause_layer: Control
var paused := false

func _ready() -> void:
	add_to_group("player")
	_make_collision()
	_make_shadow()
	_make_camera()
	_make_gun()
	_make_hud()

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
	camera.fov = 85
	camera.current = true
	camera_pivot.add_child(camera)

func _make_gun() -> void:
	gun_visual = Node3D.new()
	gun_visual.position = Vector3(0.34, -0.27, -0.62)
	camera.add_child(gun_visual)
	_add_box(Vector3.ZERO, Vector3(0.19, 0.16, 0.48), Color(0.075, 0.09, 0.11))
	_add_box(Vector3(0, 0.015, -0.34), Vector3(0.075, 0.075, 0.30), Color(0.035, 0.045, 0.055))
	_add_box(Vector3(0, -0.14, 0.07), Vector3(0.12, 0.22, 0.14), Color(0.12, 0.14, 0.15))
	var hand := MeshInstance3D.new()
	var hand_mesh := SphereMesh.new()
	hand_mesh.radius = 0.12
	hand_mesh.height = 0.24
	hand.mesh = hand_mesh
	hand.position = Vector3(-0.02, -0.12, 0.18)
	var hand_mat := StandardMaterial3D.new()
	hand_mat.albedo_color = Color(0.22, 0.78, 0.31)
	hand.material_override = hand_mat
	gun_visual.add_child(hand)

func _add_box(pos: Vector3, size: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	part.mesh = box
	part.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.5
	part.material_override = mat
	gun_visual.add_child(part)

func _make_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	var cross := Label.new()
	cross.text = "+"
	cross.add_theme_font_size_override("font_size", 30)
	cross.set_anchors_preset(Control.PRESET_CENTER)
	cross.position = Vector2(-8, -20)
	root.add_child(cross)
	hud = Label.new()
	hud.position = Vector2(22, 18)
	hud.add_theme_font_size_override("font_size", 22)
	root.add_child(hud)
	var pause_button := Button.new()
	pause_button.text = "Ⅱ"
	pause_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause_button.position = Vector2(-72, 16)
	pause_button.custom_minimum_size = Vector2(54, 48)
	pause_button.pressed.connect(_toggle_pause)
	root.add_child(pause_button)
	if OS.has_feature("mobile"):
		_add_touch_controls(root)
	_make_pause_menu(layer)
	_update_hud()

func _add_touch_controls(root: Control) -> void:
	var stick := Control.new()
	stick.position = Vector2(20, -180)
	stick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	stick.custom_minimum_size = Vector2(170, 160)
	stick.mouse_filter = Control.MOUSE_FILTER_STOP
	stick.draw.connect(func():
		stick.draw_circle(Vector2(85, 80), 72, Color(0.08, 0.08, 0.08, 0.38))
		stick.draw_circle(Vector2(85 + mobile_move.x * 45, 80 + mobile_move.y * 45), 28, Color(0.85, 0.9, 1, 0.65))
	)
	stick.gui_input.connect(func(event):
		if event is InputEventScreenTouch:
			mobile_move = Vector2.ZERO
			stick.queue_redraw()
		elif event is InputEventScreenDrag:
			mobile_move = ((event.position - stick.global_position - Vector2(85, 80)) / 65.0).limit_length(1.0)
			stick.queue_redraw()
	)
	root.add_child(stick)
	var fire := Button.new()
	fire.text = "FIRE"
	fire.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	fire.position = Vector2(-145, -160)
	fire.custom_minimum_size = Vector2(120, 95)
	fire.button_down.connect(func(): mobile_fire = true)
	fire.button_up.connect(func(): mobile_fire = false)
	root.add_child(fire)
	var jump := Button.new()
	jump.text = "JUMP"
	jump.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	jump.position = Vector2(-145, -55)
	jump.custom_minimum_size = Vector2(105, 50)
	jump.button_down.connect(func(): mobile_jump = true)
	jump.button_up.connect(func(): mobile_jump = false)
	root.add_child(jump)
	var aim_hint := Label.new()
	aim_hint.text = "Drag right side to aim"
	aim_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	aim_hint.position = Vector2(-230, -28)
	root.add_child(aim_hint)

func _make_pause_menu(layer: CanvasLayer) -> void:
	pause_layer = Control.new()
	pause_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_layer.visible = false
	pause_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(pause_layer)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.72)
	pause_layer.add_child(shade)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 230)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-150, -115)
	pause_layer.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	var resume := Button.new()
	resume.text = "Resume"
	resume.pressed.connect(_toggle_pause)
	column.add_child(resume)
	var restart := Button.new()
	restart.text = "Restart"
	restart.pressed.connect(func(): get_tree().paused = false; get_tree().reload_current_scene())
	column.add_child(restart)
	var quit := Button.new()
	quit.text = "Quit"
	quit.pressed.connect(func(): get_tree().quit())
	column.add_child(quit)

func _toggle_pause() -> void:
	paused = not paused
	get_tree().paused = paused
	pause_layer.visible = paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_toggle_pause()
	elif event is InputEventMouseButton and event.pressed and not paused and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_aim(event.relative)
	elif event is InputEventScreenDrag and event.position.x > get_viewport().get_visible_rect().size.x * 0.38:
		_aim(event.relative)

func _aim(delta: Vector2) -> void:
	rotate_y(-delta.x * mouse_sensitivity)
	pitch = clamp(pitch - delta.y * mouse_sensitivity, -1.35, 1.35)
	camera_pivot.rotation.x = pitch

func _physics_process(delta: float) -> void:
	if paused:
		return
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	if (Input.is_action_pressed("fire") or mobile_fire) and fire_cooldown <= 0:
		_fire()
		fire_cooldown = fire_rate
	if not is_on_floor():
		velocity.y -= gravity * delta
	if (Input.is_action_just_pressed("jump") or mobile_jump) and is_on_floor():
		velocity.y = jump_velocity
	var move := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if mobile_move.length() > 0.08:
		move = mobile_move
	var direction := (transform.basis * Vector3(move.x, 0, move.y)).normalized()
	velocity.x = direction.x * walk_speed if direction != Vector3.ZERO else move_toward(velocity.x, 0.0, walk_speed * 8 * delta)
	velocity.z = direction.z * walk_speed if direction != Vector3.ZERO else move_toward(velocity.z, 0.0, walk_speed * 8 * delta)
	move_and_slide()

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
	if health <= 0:
		paused = true
		get_tree().paused = true
		pause_layer.visible = true

func heal(amount: float) -> void:
	health = minf(100, health + amount)
	_update_hud()

func add_ammo(amount: int) -> void:
	ammo += amount
	_update_hud()

func _update_hud() -> void:
	if is_instance_valid(hud):
		hud.text = "HP %d / 100     AMMO %d" % [int(health), ammo]
