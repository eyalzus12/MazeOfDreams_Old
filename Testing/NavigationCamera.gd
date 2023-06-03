extends Camera2D

const CAMERA_ACCELERATION := 40.
const CAMERA_SPEED := 400.
const MAXZOOM_IN := 0
const MAXZOOM_OUT := INF
const ZOOM_INTERVAL = .1

func _process(_delta: float) -> void:
	zoom = Vector2.ONE/zoom
	var speed_mult := zoom.x/10
	var offset_vector := Vector2.ZERO
	if Input.is_action_pressed("ui_left"): offset_vector += speed_mult*CAMERA_ACCELERATION*Vector2.LEFT
	if Input.is_action_pressed("ui_right"): offset_vector += speed_mult*CAMERA_ACCELERATION*Vector2.RIGHT
	if Input.is_action_pressed("ui_down"): offset_vector += speed_mult*CAMERA_ACCELERATION*Vector2.DOWN
	if Input.is_action_pressed("ui_up"): offset_vector += speed_mult*CAMERA_ACCELERATION*Vector2.UP
	offset_vector.x = max(-CAMERA_SPEED, min(offset_vector.x, speed_mult*CAMERA_SPEED))
	offset_vector.y = max(-CAMERA_SPEED, min(offset_vector.y, speed_mult*CAMERA_SPEED))
	offset += offset_vector
	var zoom_factor := 0.
	if Input.is_action_pressed("ui_zoom_in"): zoom_factor -= speed_mult*ZOOM_INTERVAL
	if Input.is_action_pressed("ui_zoom_out"): zoom_factor += speed_mult*ZOOM_INTERVAL
	zoom += zoom_factor*Vector2.ONE
	var zoomx: float = max(MAXZOOM_IN, min(zoom.x, MAXZOOM_OUT))
	var zoomy: float = max(MAXZOOM_IN, min(zoom.y, MAXZOOM_OUT))
	zoom = Vector2(zoomx,zoomy)
	zoom = Vector2.ONE/zoom
