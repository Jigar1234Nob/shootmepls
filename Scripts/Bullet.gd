extends Node3D

@export var speed := 150.0
@export var damage := 12.5
@export var lifetime := 2.5
var direction := Vector3.FORWARD
var age := 0.0

func _ready() -> void:
	var visual := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.055
	mesh.height = 0.11
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.82, 0.22)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.42, 0.05)
	material.emission_energy_multiplier = 2.5
	visual.material_override = material
	add_child(visual)

func _physics_process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return

	var start := global_position
	var finish := start + direction.normalized() * speed * delta
	var query := PhysicsRayQueryParameters3D.create(start, finish, 2)
	query.collide_with_areas = false
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var collider = hit.get("collider")
		if collider != null and collider.has_method("take_damage"):
			collider.take_damage(damage)
		queue_free()
		return
	global_position = finish
