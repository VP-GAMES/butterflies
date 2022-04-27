@tool
extends MultiMeshInstance3D

@export var max_x: float = 5.0
@export var max_y: float = 5.0
@export var max_z: float = 5.0
@export var speed_rotation: float = 0.02
@export var speed: float = 0.5

var _from: Array[Vector3] = []
var _to: Array[Vector3] = []
var _time: Array[float] = []

func _ready():
	for i in range(multimesh.instance_count):
		_from.append(Vector3(_randf(max_x), _randf(max_y, true), _randf(max_z)))
		_to.append(Vector3(_randf(max_x), _randf(max_y, true), _randf(max_z)))
		_time.append(0.0)
		var pos = Transform3D()
		pos = pos.translated(_from[i])
		multimesh.set_instance_transform(i, pos)

func _randf(max_value: float, absolut: bool = false) -> float:
	var _pos_neg = 1 if randf() > 0.5 else -1
	if absolut:
		_pos_neg = 1
	return randf() * max_value * _pos_neg

func _process(delta):
	for i in range(multimesh.instance_count):
		var pos: Transform3D = multimesh.get_instance_transform(i)
		var _from_pos = Transform3D()
		_from_pos = _from_pos.translated(_from[i])
		var _to_pos = Transform3D()
		_to_pos = _to_pos.translated(_to[i])
		var current_rot = Quaternion(pos.basis)
		var target_rot = Quaternion(pos.looking_at(_to[i]).basis)
		var smoothrot = current_rot.slerp(target_rot, speed_rotation * randf())
		pos.basis = Basis(smoothrot)
		_time[i] = _time[i] + delta * speed
		pos = _from_pos.interpolate_with(_to_pos, _time[i])
		pos.basis = Basis(smoothrot)
		multimesh.set_instance_transform(i, pos)
		if _time[i] >= 1.0:
			_from[i] = _to[i]
			_to[i] = Vector3(_randf(max_x), _randf(max_y, true), _randf(max_z))
			_time[i] = 0.0
