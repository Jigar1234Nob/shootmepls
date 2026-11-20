extends CharacterBody3D
class_name FPSPlayer

signal health_changed(value: int, maximum: int)
signal ammo_changed(clip: int, reserve: int)
signal died

@export var walk_speed := 7.0
@export var sprint_speed := 10.5
@export var jump_velocity := 5.5
@export var mouse_sensitivity := 0.0022
@export var max_health := 100
@export var damage := 25
@export var fire_delay := 0.18

var health := 100
var clip_size := 12
var ammo_in_clip := 12
var reserve_ammo := 60
var reloading := false
var can_fire := true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var head: Node3D
var camera: Camera3D
var weapon_root: Node3D
var weapon_home := Vector3(0.34, -0.29, -0.58)
var bob_time := 0.0
var recoil := 0.0
var is_crouching := false

func _ready() -> void:
	health = max_health
	add_to_group("player")
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.8
	var collision := CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = 0.9
	add_child(collision)
	head = Node3D.new()
	head.name = "Head"
	head.position.y = 1.58
	add_child(head)
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 82.0
	head.add_child(camera)
	_build_viewmodel()
	health_changed.emit(health, max_health)
	ammo_changed.emit(ammo_in_clip, reserve_ammo)

func _build_viewmodel() -> void:
	weapon_root = Node3D.new()
	weapon_root.name = "FirstPersonArmsAndGun"
	weapon_root.position = weapon_home
	camera.add_child(weapon_root)
	# Sleeved forearm and hand.
	_box(weapon_root, Vector3(-0.19, -0.20, -0.02), Vector3(0.16, 0.18, 0.48), Color(0.18, 0.27, 0.38))
	_box(weapon_root, Vector3(-0.17, -0.15, -0.28), Vector3(0.17, 0.14, 0.20), Color(0.73, 0.48, 0.32))
	# Generic compact rifle silhouette, built from textured-looking material blocks.
	_box(weapon_root, Vector3(0.02, -0.04, -0.20), Vector3(0.19, 0.17, 0.52), Color(0.075, 0.09, 0.105))
	_box(weapon_root, Vector3(0.02, 0.01, -0.53), Vector3(0.075, 0.075, 0.34), Color(0.035, 0.045, 0.055))
	_box(weapon_root, Vector3(0.02, -0.15, -0.18), Vector3(0.12, 0.20, 0.16), Color(0.12, 0.14, 0.15))
	_box(weapon_root, Vector3(0.02, 0.09, -0.17), Vector3(0.10, 0.055, 0.24), Color(0.16, 0.18, 0.19))
	_box(weapon_root, Vector3(0.02, 0.12, -0.17), Vector3(0.055, 0.035, 0.13), Color(0.025, 0.03, 0.035))
	_box(weapon_root, Vector3(0.02, -0.10, -0.12), Vector3(0.11, 0.12, 0.13), Color(0.055, 0.065, 0.075))

func _box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.55 if color.r < 0.2 else 0.05
	mat.roughness = 0.42
	instance.material_override = mat
	parent.add_child(instance)
	return instance

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -1.48, 1.48)
	if event.is_action_pressed("reload"):
		reload_weapon()
	if event.is_action_pressed("fire") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		shoot()
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity
	if Input.is_action_just_pressed("crouch"):
		is_crouching = not is_crouching
		var tween := create_tween()
		tween.tween_property(head, "position:y", 1.05 if is_crouching else 1.58, 0.16)
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		bob_time += delta * (13.0 if speed == sprint_speed else 9.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, walk_speed * 7.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, walk_speed * 7.0 * delta)
	if is_on_floor() and weapon_root:
		weapon_root.position.y = weapon_home.y + (sin(bob_time) * 0.012 if direction != Vector3.ZERO else 0.0)
	recoil = move_toward(recoil, 0.0, delta * 5.5)
	if weapon_root:
		weapon_root.rotation.x = -recoil
	move_and_slide()

func shoot() -> void:
	if not can_fire or reloading or health <= 0:
		return
	if ammo_in_clip <= 0:
		reload_weapon()
		return
	ammo_in_clip -= 1
	ammo_changed.emit(ammo_in_clip, reserve_ammo)
	recoil = 0.075
	can_fire = false
	var timer := get_tree().create_timer(fire_delay)
	timer.timeout.connect(func(): can_fire = true)
	var origin := camera.global_position
	var direction := -camera.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 100.0)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var target: Object = hit.collider
		if target and target.has_method("take_damage"):
			target.take_damage(damage)

func reload_weapon() -> void:
	if reloading or ammo_in_clip >= clip_size or reserve_ammo <= 0:
		return
	reloading = true
	can_fire = false
	var tween := create_tween()
	tween.tween_property(weapon_root, "position:y", weapon_home.y - 0.20, 0.22)
	tween.tween_property(weapon_root, "rotation:x", 0.28, 0.22)
	tween.tween_interval(0.45)
	tween.tween_property(weapon_root, "rotation:x", 0.0, 0.2)
	tween.tween_property(weapon_root, "position:y", weapon_home.y, 0.2)
	tween.finished.connect(func():
		var needed := clip_size - ammo_in_clip
		var loaded: int = mini(needed, reserve_ammo)
		ammo_in_clip += loaded
		reserve_ammo -= loaded
		reloading = false
		can_fire = true
		ammo_changed.emit(ammo_in_clip, reserve_ammo)
	)

func take_damage(amount: int) -> void:
	if health <= 0:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	if health == 0:
		died.emit()

func heal(amount: int) -> void:
	health = mini(max_health, health + amount)
	health_changed.emit(health, max_health)

func add_ammo(amount: int) -> void:
	reserve_ammo += amount
	ammo_changed.emit(ammo_in_clip, reserve_ammo)

func upgrade_damage(amount: int) -> void:
	damage += amount
