@tool
extends MultiMeshInstance3D

@export var max_x: float = 5.0
@export var max_y: float = 5.0
@export var max_z: float = 5.0
@export var mesh_scale: Vector3 = Vector3.ONE
@export var speed_rotation: float = 0.02
@export var speed: float = 0.5

var _from: Array[Vector3] = []
var _to: Array[Vector3] = []
var _time_interpolation: Array[float] = []
var _time_slerp: Array[float] = []

func _ready():
	for i in range(multimesh.instance_count):
		_from.append(Vector3(_randf(max_x, mesh_scale.x), _randf(max_y, mesh_scale.y, true), _randf(max_z, mesh_scale.z)))
		_to.append(Vector3(_randf(max_x, mesh_scale.x), _randf(max_y, mesh_scale.y, true), _randf(max_z, mesh_scale.z)))
		_time_interpolation.append(0.0)
		_time_slerp.append(0.0)
		var pos = Transform3D()
		pos = pos.translated(_from[i])
		pos = pos.scaled(mesh_scale)
		multimesh.set_instance_transform(i, pos)

func _randf(max_value: float, scale_mesh: float, absolut: bool = false) -> float:
	var _pos_neg = 1 if randf() > 0.5 else -1
	if absolut:
		_pos_neg = 1
	var value = max_value
	if scale_mesh > 1:
		value = max_value * scale_mesh
	else:
		value = max_value / scale_mesh
	return randf() * value * _pos_neg

func _process(delta):
	for i in range(multimesh.instance_count):
		_time_interpolation[i] = _time_interpolation[i] + delta * speed
		if _time_slerp[i] < 1.0:
			_time_slerp[i] = _time_slerp[i] + delta * speed_rotation
		var pos: Transform3D = multimesh.get_instance_transform(i)
		var _from_pos = Transform3D()
		_from_pos = _from_pos.translated(_from[i])
		var _to_pos = Transform3D()
		_to_pos = _to_pos.translated(_to[i])
		pos = pos.orthonormalized()
		pos = _from_pos.interpolate_with(_to_pos, _time_interpolation[i])
		pos.basis = pos.basis.slerp(pos.looking_at(_to[i]).basis, _time_slerp[i])
		pos = pos.scaled(mesh_scale)
		multimesh.set_instance_transform(i, pos)
		if _time_interpolation[i] >= 1.0:
			_from[i] = _to[i]
			_to[i] = Vector3(_randf(max_x, mesh_scale.x), _randf(max_y, mesh_scale.y, true), _randf(max_z, mesh_scale.z))
			_time_interpolation[i] = 0.0
			if _time_slerp[i] >= 1.0:
				_time_slerp[i] = 0.0
