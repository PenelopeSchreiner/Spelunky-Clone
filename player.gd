extends CharacterBody2D


const SPEED = 200.0
const SPRINT_SPEED = 275.0
const JUMP_VELOCITY = -400.0

# -- flags
var is_sprinting := false
var is_climbing := false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")




func jump():
	velocity.y = JUMP_VELOCITY

func jump_cut():
	if velocity.y < -100:
		velocity.y = -100


func _process(delta):
	
	if Input.is_action_pressed("Sprint"):
		is_sprinting = true
	
	if Input.is_action_just_released("Sprint"):
		is_sprinting = false


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("Accept") and is_on_floor():
		jump()
	
	if Input.is_action_just_released("Accept"):
		jump_cut()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		if is_sprinting:
			velocity.x = direction * SPRINT_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		if is_sprinting:
			velocity.x = move_toward(velocity.x, 0, SPRINT_SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
