extends Node
class_name PivotCam

@export var look_angles: Vector2
@export var pivot_position: Vector3
var applied_offset: Vector3
var applied_zoom: float

var orbit_sensitivity: float = 1.0
var move_sensitivity: float = 0.0012
var zoom_sensitivity: float = .07

var camera: CameraSystem

func _ready():
	camera = get_node("%CameraSystem")
	pivot_position = Vector3(15.0, 0.0, 0.0)

func process(delta: float):
	rotate_camera()

func rotate_camera() -> void:
	## doing this in process is smoother than in input
	camera.position += applied_offset
	pivot_position += applied_offset
	applied_offset = Vector3.ZERO
	
	look_angles.y = clamp(look_angles.y, -90, 90)
	if look_angles.x > 360: look_angles.x += -360
	if look_angles.x < 0: look_angles.x += 360
	camera.rotation_degrees = Vector3(look_angles.y, look_angles.x, 0)
	var dist = pivot_position.distance_to(camera.position) + applied_zoom
	camera.position = pivot_position + camera.basis.z.normalized() * dist
	
	applied_zoom = 0.0
	
func handle_mouse(event: InputEvent):
	if !Input.is_action_pressed("orbit_general"):
		return
	if Input.is_action_pressed("orbit_pan"):
		var forward = camera.basis.z.normalized()
		var right = Vector3.UP.cross(forward).normalized()
		var up = forward.cross(right)
		applied_offset += (-right * event.relative.x + up * event.relative.y) * move_sensitivity * pivot_position.distance_to(camera.position)
	else:
		look_angles += -event.relative * UserPreferences.free_cam_sensitivity * orbit_sensitivity
			
func _input(event):
	if camera.current_camera_mode != CameraSystem.CameraMode.pivot_cam:
		return
	if event is not InputEventMouseButton:
		return
		
func handle_scroll(event: InputEvent):
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		applied_zoom -= zoom_sensitivity * pivot_position.distance_to(camera.position)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: 
		applied_zoom += zoom_sensitivity * max(2.0, pivot_position.distance_to(camera.position))
