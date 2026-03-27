extends Camera3D
class_name CameraSystem

var current_camera_mode: CameraMode = CameraMode.free_cam

enum CameraMode {
	free_cam,
	pivot_cam,
	ortho_pivot_cam,
	ortho_side_cam
}
	
