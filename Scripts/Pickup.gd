extends Area3D
class_name WorldPickup

@export_enum("ammo", "health") var pickup_type := "ammo"
@export var amount := 24
var base_y := 0.5
var age := 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.0
	shape.shape = sphere
	add_child(shape)
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.48, 0.48, 0.48)
	visual.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.72, 0.12) if pickup_type == "ammo" else Color(0.15, 0.9, 0.42)
	mat.emission_enabled = true
	mat.emission = mat.albedo_color * 0.35
	visual.material_override = mat
	add_child(visual)
	base_y = position.y
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	age += delta
	rotation.y += delta * 1.4
	position.y = base_y + sin(age * 2.5) * 0.12

func _on_body_entered(body: Node3D) -> void:
	if not body is FPSPlayer:
		return
	if pickup_type == "ammo":
		body.add_ammo(amount)
	else:
		if body.health >= body.max_health:
			return
		body.heal(amount)
	queue_free()
