extends KinematicBody2D

const SPEED = 400
const GRAVITY = 900
const JUMP_FORCE = -600

var velocity = Vector2()
var on_ground = false

onready var tween = $Tween

puppet var puppet_position = Vector2() setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_on_ground = true


func _physics_process(delta: float):
	velocity.y += GRAVITY * delta
	
	if is_network_master():
		handle_input()
		velocity = move_and_slide(velocity, Vector2.UP)
		on_ground = is_on_floor()
	else:
		if not tween.is_active():
			move_and_slide(puppet_velocity*SPEED)
		on_ground = puppet_on_ground

func handle_input():
	var x_input = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	velocity.x = x_input * SPEED
	
	if Input.is_action_just_pressed("ui_up") and on_ground:
		velocity.y = JUMP_FORCE
		on_ground = false
		

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "position", position, puppet_position, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	

func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", position)
		rset_unreliable("puppet_on_ground", on_ground)
		rset_unreliable("puppet_velocity", velocity)


func apply_operation(operation: Dictionary):
	match operation.action:
		"move_left":
			velocity.x = -SPEED
		"move_right":
			velocity.x = SPEED
		"jump":
			if on_ground:
				velocity.y = JUMP_FORCE
				on_ground = false

