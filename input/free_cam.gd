extends Node
class_name FreeCam

## Yummy magic numbers
var acceleration: float = 50
var drag: float = 3.0
var linear_drag: float = 5
var sensitivity_multiplier: float = .4

@export var speed_multiplier: float = 7.0
@export var max_pitch: float = .95
@export var min_pitch: float = -.95
@export var look_angles: Vector2
@export var velocity: Vector3

var camera_system: CameraSystem

func _ready():
	camera_system = %CameraSystem

func _input(event: InputEvent):	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("free_cam_look"):
			look_angles += -event.relative * UserPreferences.free_cam_sensitivity * sensitivity_multiplier

func _process(delta: float):
	if camera_system.current_camera_mode != CameraSystem.CameraMode.free_cam:
		return

	rotate_camera()
	move_camera(delta)

func rotate_camera() -> void:
	look_angles.y = clamp(look_angles.y, -90, 90)
	if look_angles.x > 360: look_angles.x += -360
	if look_angles.x < 0: look_angles.x += 360
	camera_system.rotation_degrees = Vector3(look_angles.y, look_angles.x, 0)

func move_camera(delta: float) -> void:
	var inputting = Input.is_action_pressed("cam_down") or Input.is_action_pressed("cam_up") or \
	Input.get_vector("cam_left", "cam_right", "cam_forward", "cam_back") != Vector2.ZERO
	velocity = Vector3.ZERO if velocity.length() < .05 and !inputting else velocity
	velocity += delta * linear_drag * -velocity.normalized()
	velocity *= 1 - drag * delta
	if Input.is_action_pressed("cam_up"):
		velocity += Vector3.UP * delta * acceleration
	if Input.is_action_pressed("cam_down"):
		velocity += Vector3.DOWN * delta * acceleration
	var plane_movement = Input.get_vector("cam_left", "cam_right", "cam_forward", "cam_back") * delta * acceleration
	var cos = cos(deg_to_rad(camera_system.rotation_degrees.y))
	var sin = sin(deg_to_rad(camera_system.rotation_degrees.y))
	plane_movement = plane_movement.x * Vector2(cos, -sin) + plane_movement.y * Vector2(sin, cos)
	velocity.x += plane_movement.x
	velocity.z += plane_movement.y
	camera_system.position += velocity * speed_multiplier * delta
