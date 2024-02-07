extends CharacterBody2D

var air_jump = false
var just_wall_jumped = false
@export var movement_data: PlayerMovmentData
@onready var coyote_jump_timer = $coyoteJumpTimer
@onready var animated_sprite_2d = $AnimatedSprite2D
# Get the gravity from the project settings to b e synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()
	var input_axis = Input.get_axis("ui_left", "ui_right")
	handle_acceration(input_axis, delta)
	apply_air_reistance(input_axis, delta)
	apply_friction(input_axis,delta)
	move_and_slide()
	handle_air_accelertation(input_axis, delta)
	upadte_amainction(input_axis)
	var was_on_foor= is_on_floor()
	move_and_slide()
	var just_left_ledge= was_on_foor and not is_on_floor() and velocity.y >=0
	if just_left_ledge:
		coyote_jump_timer.start()
	just_wall_jumped = false
		
		
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity* movement_data.gravity_scale * delta
		
func handle_wall_jump():
	if not is_on_wall_only(): return
	var wall_normal = get_wall_normal() 
	if Input.is_action_just_pressed("ui_up"):
		velocity.x = wall_normal.x * movement_data.SPEED
		velocity.y = movement_data.JUMP_VELOCITY
		just_wall_jumped = true
	#if Input.is_action_just_pressed("ui_up") and wall_normal == Vector2.RIGHT:
		#velocity.x = wall_normal.x * movement_data.SPEED
		#velocity.y = movement_data.JUMP_VELOCITY
		
		

func handle_jump():
	if is_on_floor(): air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left >0.0:
		if Input.is_action_just_pressed("ui_up") and is_on_floor():
			velocity.y = movement_data.JUMP_VELOCITY
	if not is_on_floor():
		if Input.is_action_just_released("ui_up") and velocity.y < movement_data.JUMP_VELOCITY / 2:
			velocity.y = movement_data.JUMP_VELOCITY / 2
			
		if Input.is_action_just_pressed("ui_up") and air_jump and not just_wall_jumped:
			velocity.y = movement_data.JUMP_VELOCITY * 0.8
			air_jump = false
			
func handle_acceration(input_axis,delta):
	if not is_on_floor(): return
	if input_axis!= 0:
		velocity.x = move_toward(velocity.x, movement_data.SPEED * input_axis, movement_data.acceleration * delta)

func handle_air_accelertation(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.SPEED* input_axis, movement_data.air_acceleration* delta)	
func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x,0,movement_data.friction*delta)
			

func apply_air_reistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x=move_toward(velocity.x,0, movement_data.air_resitanece)
func upadte_amainction(input_axis):
	if input_axis !=0:
		animated_sprite_2d.flip_h = (input_axis <0)
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
		
	if not is_on_floor():
		animated_sprite_2d.play("jump")
