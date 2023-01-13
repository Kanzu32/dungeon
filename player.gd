extends KinematicBody

#onready var camera = $Pivot/Camera
onready var weaponAnimator = $Pivot/Arm/weapon/AnimationTree
onready var weaponStateMachine = weaponAnimator["parameters/playback"]

var gravity = -30
var jumpForce = 150
var max_speed = 5
var mouse_sensivity = 0.002
var attack_is_on_cooldown = false
var cooldown_timer = Timer.new()
var velocity = Vector3()


func start_cooldown_timer():
	attack_is_on_cooldown = true
	cooldown_timer.wait_time = 1.3
	cooldown_timer.one_shot = true
	cooldown_timer.start()

func attack_is_ready():
	attack_is_on_cooldown = false;

func _ready():
	cooldown_timer.connect("timeout",self,"attack_is_ready")
	add_child(cooldown_timer)

func get_directional_input():
	var input_dir = Vector3()
	
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_pressed("left_button"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().set_input_as_handled()
		
	
	if Input.is_action_pressed("move_forward"):
		input_dir += -global_transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += global_transform.basis.x
	if Input.is_action_pressed("jump") and is_on_floor():
		input_dir += global_transform.basis.y
	
	input_dir = input_dir.normalized()
	return input_dir

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensivity)
		$Pivot.rotate_x(-event.relative.y * mouse_sensivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -1.2, 1.2)

func _physics_process(delta):
	
	var desired_velocity = get_directional_input() * max_speed
	if (Input.is_action_just_pressed("attack") and not attack_is_on_cooldown):
		weaponStateMachine.start("attack")
		start_cooldown_timer()
	elif (desired_velocity == Vector3.ZERO):
		weaponStateMachine.travel("idle")
	else:
		weaponStateMachine.travel("walk")
	
	velocity.x = desired_velocity.x
	velocity.y += gravity * delta + desired_velocity.y * jumpForce * delta
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
