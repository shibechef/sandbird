extends Camera3D
class_name CameraSystem

var current_camera_mode: CameraMode = CameraMode.pivot_cam

var free_cam: FreeCam
var pivot_cam: PivotCam

func _ready():
	free_cam = get_node("%FreeCam")
	pivot_cam = get_node("%PivotCam")

func _input(event: InputEvent):
	handle_mouse_motion(event)

func handle_mouse_motion(event: InputEvent):
	if event is not InputEventMouseMotion:
		return

	match current_camera_mode:
		CameraMode.free_cam:
			free_cam.handle_mouse(event)
		CameraMode.pivot_cam:
			pivot_cam.handle_mouse(event)
		CameraMode.ortho_pivot_cam:
			return
		CameraMode.ortho_side_cam:
			return

func handle_scroll_motion(event: InputEvent) -> bool: 
	match current_camera_mode:
		CameraMode.free_cam:
			return false
		CameraMode.pivot_cam:
			pivot_cam.handle_scroll(event)
			return true
		CameraMode.ortho_pivot_cam:
			return false
		CameraMode.ortho_side_cam:
			return false
	return false

func _process(delta):
	match current_camera_mode:
		CameraMode.free_cam:
			free_cam.process(delta)
		CameraMode.pivot_cam:
			pivot_cam.process(delta)
		CameraMode.ortho_pivot_cam:
			return
		CameraMode.ortho_side_cam:
			return

enum CameraMode {
	free_cam,
	pivot_cam,
	ortho_pivot_cam,
	ortho_side_cam
}
	
