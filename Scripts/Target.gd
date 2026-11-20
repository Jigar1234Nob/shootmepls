extends StaticBody3D

@export var max_health := 100.0
var health := 100.0
var health_label: Label3D
var number_label: Label3D

func _ready() -> void:
	collision_layer = 2
	collision_mask = 0
	health = max_health
	_make_target()
	_make_health_bar()
	_update_health_bar()

func _make_target() -> void:
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.78
	collision.shape = shape
	collision.position.y = 1.0
	add_child(collision)

	var body := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.72
	mesh.height = 1.8
	body.mesh = mesh
	body.position.y = 1.0
	body.scale = Vector3(0.82, 1.0, 0.82)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.92, 0.24, 0.16)
	mat.roughness = 0.7
	body.material_override = mat
	add_child(body)

	var bullseye := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.34
	disc.bottom_radius = 0.34
	disc.height = 0.035
	bullseye.mesh = disc
	bullseye.position = Vector3(0, 1.0, -0.61)
	bullseye.rotation_degrees.x = 90
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(1.0, 0.94, 0.82)
	bullseye.material_override = white
	add_child(bullseye)

	var centre := MeshInstance3D.new()
	var centre_mesh := SphereMesh.new()
	centre_mesh.radius = 0.13
	centre_mesh.height = 0.26
	centre.mesh = centre_mesh
	centre.position = Vector3(0, 1.0, -0.66)
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.12, 0.13, 0.15)
	centre.material_override = dark
	add_child(centre)

func _make_health_bar() -> void:
	health_label = Label3D.new()
	health_label.name = "HealthBar"
	health_label.position = Vector3(0, 2.25, 0)
	health_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	health_label.font_size = 64
	health_label.outline_size = 10
	health_label.pixel_size = 0.003
	health_label.no_depth_test = true
	add_child(health_label)

	number_label = Label3D.new()
	number_label.name = "HealthNumber"
	number_label.position = Vector3(0, 2.62, 0)
	number_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	number_label.font_size = 36
	number_label.outline_size = 8
	number_label.pixel_size = 0.003
	number_label.no_depth_test = true
	add_child(number_label)

func take_damage(amount: float) -> void:
	if health <= 0.0:
		return
	health = maxf(0.0, health - amount)
	_update_health_bar()
	if health <= 0.0:
		queue_free()

func _update_health_bar() -> void:
	var filled := int(ceil(health / max_health * 10.0))
	health_label.text = "█".repeat(filled) + "░".repeat(10 - filled)
	health_label.modulate = Color(0.25, 1.0, 0.28) if health > 50.0 else (Color(1.0, 0.75, 0.12) if health > 20.0 else Color(1.0, 0.2, 0.15))
	number_label.text = "%d / %d HP" % [int(health), int(max_health)]
