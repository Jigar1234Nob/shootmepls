extends CharacterBody3D
class_name FPSPlayer

@export var walk_speed := 7.0
@export var sprint_speed := 10.5
@export var jump_velocity := 5.5
@export var mouse_sensitivity := 0.0025

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_pivot: Node3D
var camera: Camera3D
var pitch := -0.12
var bean_visual: Node3D
var gun_visual: Node3D
var bob_time := 0.0

func _ready() -> void:
	name = "PlayerBean"
	_make_collision()
	_make_bean()
	_make_gun()
	_make_camera()

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
	bean_visual.name = "Bean"
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
	bean_mat.roughness = 0.68
	bean_mat.metallic = 0.0
	body.material_override = bean_mat
	bean_visual.add_child(body)

	# Small simple eyes give the bean a readable front.
	for x in [-0.19, 0.19]:
		var eye := MeshInstance3D.new()
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.075
		eye_mesh.height = 0.15
		eye.mesh = eye_mesh
		eye.position = Vector3(x, 1.25, -0.49)
		var eye_mat := StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.98, 0.99, 1.0)
		eye.material_override = eye_mat
		bean_visual.add_child(eye)

		var pupil := MeshInstance3D.new()
		var pupil_mesh := SphereMesh.new()
		pupil_mesh.radius = 0.034
		pupil_mesh.height = 0.068
		pupil.mesh = pupil_mesh
		pupil.position = Vector3(x, 1.25, -0.55)
		var pupil_mat := StandardMaterial3D.new()
		pupil_mat.albedo_color = Color(0.025, 0.035, 0.045)
		pupil.material_override = pupil_mat
		bean_visual.add_child(pupil)

func _make_gun() -> void:
	gun_visual = Node3D.new()
	gun_visual.name = "Gun"
	gun_visual.position = Vector3(0.48, 1.05, -0.42)
	bean_visual.add_child(gun_visual)

	_add_gun_box(Vector3.ZERO, Vector3(0.20, 0.18, 0.52), Color(0.075, 0.09, 0.11))
	_add_gun_box(Vector3(0.0, 0.02, -0.39), Vector3(0.085, 0.085, 0.34), Color(0.035, 0.045, 0.055))
	_add_gun_box(Vector3(0.0, -0.16, 0.08), Vector3(0.13, 0.24, 0.16), Color(0.12, 0.14, 0.15))
	_add_gun_box(Vector3(0.0, 0.12, -0.02), Vector3(0.12, 0.06, 0.24), Color(0.18, 0.2, 0.22))
	_add_gun_box(Vector3(-0.015, 0.02, 0.27), Vector3(0.14, 0.14, 0.25), Color(0.09, 0.11, 0.13))

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

func _make_camera() -> void:
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	camera_pivot.position = Vector3(0, 1.35, 0)
	add_child(camera_pivot)

	camera = Camera3D.new()
	camera.name = "ThirdPersonCamera"
	camera.position = Vector3(0.0, 1.0, 5.8)
	camera.rotation.x = pitch
	camera.fov = 75.0
	camera.current = true
	camera_pivot.add_child(camera)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, -0.75, 0.35)
		camera.rotation.x = pitch

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
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
		bean_visual.position.y = sin(bob_time) * 0.035
		gun_visual.rotation.z = sin(bob_time) * 0.025
	else:
		velocity.x = move_toward(velocity.x, 0.0, walk_speed * 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, walk_speed * 8.0 * delta)
		bean_visual.position.y = move_toward(bean_visual.position.y, 0.0, delta * 0.12)
		gun_visual.rotation.z = move_toward(gun_visual.rotation.z, 0.0, delta * 0.1)

	move_and_slide()
