extends KinematicBody


var gravity = -30
var max_speed = 4

var velocity = Vector3()

func _ready():
	$AnimatedSprite3D.play("idle");

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP, true)
