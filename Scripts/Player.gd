extends CharacterBody3D
class_name FPSPlayer

@export var walk_speed := 7.0
@export var sprint_speed := 10.5
@export var jump_velocity := 5.5
@export var mouse_sensitivity := 0.0025
@export var fire_rate := 0.075

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_pivot: Node3D
var camera: Camera3D
var pitch := 0.0
var bean_visual: Node3D
var gun_visual: Node3D
var bob_time := 0.0
var shot_cooldown := 0.0
var shots_fired := 0

func _ready() -> void:
	name = "PlayerBean"
	_make_collision()
	_make_bean()
	_make_camera()
	_make_gun()

func _make_collision() -> void:
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.55
	capsule.height = 2.0
	collision.shape = capsule
	collision.position.y = 1.0
	add_child(collision)

func _make_bean() -> void:
	bean_visual = Node3D.new()
	bean_visual.name = "BeanBodyHiddenInFirstPerson"
	bean_visual.visible = false
	add_child(bean_visual)

	var body := MeshInstance3D.new()
	var bean_mesh := SphereMesh.new()
	bean_mesh.radius = 0.72
	bean_mesh.height = 1.9
	body.mesh = bean_mesh
	body.position.y = 1.0
	body.scale = Vector3(0.78, 1.0, 0.72)
	var bean_mat := StandardMaterial3D.new()
	bean_mat.albedo_color = Color(0.22, 0.78, 0.31)
	body.material_override = bean_mat
	bean_visual.add_child(body)

func _make_camera() -> void:
	camera_pivot = Node3D.new()
	camera_pivot.name = "FirstPersonCameraPivot"
	camera_pivot.position = Vector3(0, 1.48, 0)
	add_child(camera_pivot)

	camera = Camera3D.new()
	camera.name = "FirstPersonCamera"
	camera.position = Vector3.ZERO
	camera.fov = 85.0
	camera.current = true
	camera_pivot.add_child(camera)

func _make_gun() -> void:
	gun_visual = Node3D.new()
	gun_visual.name = "FirstPersonGun"
	gun_visual.position = Vector3(0.34, -0.27, -0.62)
	camera.add_child(gun_visual)

	_add_gun_box(Vector3.ZERO, Vector3(0.19, 0.16, 0.48), Color(0.075, 0.09, 0.11))
	_add_gun_box(Vector3(0.0, 0.015, -0.34), Vector3(0.075, 0.075, 0.30), Color(0.035, 0.045, 0.055))
	_add_gun_box(Vector3(0.0, -0.14, 0.07), Vector3(0.12, 0.22, 0.14), Color(0.12, 0.14, 0.15))
	_add_gun_box(Vector3(0.0, 0.105, -0.02), Vector3(0.11, 0.05, 0.22), Color(0.18, 0.2, 0.22))
	_add_gun_box(Vector3(0.0, 0.02, 0.25), Vector3(0.13, 0.13, 0.22), Color(0.09, 0.11, 0.13))

	var hand := MeshInstance3D.new()
	var hand_mesh := SphereMesh.new()
	hand_mesh.radius = 0.12
	hand_mesh.height = 0.24
	hand.mesh = hand_mesh
	hand.position = Vector3(-0.02, -0.12, 0.18)
	hand.scale = Vector3(1.0, 0.8, 1.3)
	var hand_mat := StandardMaterial3D.new()
	hand_mat.albedo_color = Color(0.22, 0.78, 0.31)
	hand.material_override = hand_mat
	gun_visual.add_child(hand)

func _add_gun_box(pos: Vector3, size: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	part.mesh = box
	part.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.55
	mat.roughness = 0.38
	part.material_override = mat
	gun_visual.add_child(part)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, -1.35, 1.35)
		camera_pivot.rotation.x = pitch

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	shot_cooldown = maxf(0.0, shot_cooldown - delta)
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_pressed("fire") and shot_cooldown <= 0.0:
		_fire_bullet()
		shot_cooldown = fire_rate

	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		bob_time += delta * 9.0
		gun_visual.position.y = -0.27 + sin(bob_time) * 0.012
	else:
		velocity.x = move_toward(velocity.x, 0.0, walk_speed * 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, walk_speed * 8.0 * delta)
		gun_visual.position.y = move_toward(gun_visual.position.y, -0.27, delta * 0.1)
	move_and_slide()

func _fire_bullet() -> void:
	var bullet = preload("res://Scripts/Bullet.gd").new()
	var direction := -camera.global_transform.basis.z
	bullet.global_position = camera.global_position + direction * 0.85
	bullet.direction = direction
	get_tree().current_scene.add_child(bullet)
	shots_fired += 1
	gun_visual.position.z = -0.54
	await get_tree().create_timer(0.035).timeout
	if is_instance_valid(gun_visual):
		gun_visual.position.z = -0.62
