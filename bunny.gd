extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


@onready var _animated_sprite = $AnimatedSprite2D
#
#
#func _physics_process(delta: float) -> void:
	### Add the gravity.
	##if not is_on_floor():
		##velocity += get_gravity() * delta

	### Handle jump.
	##if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		##velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()


func _process(_delta):
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		if _animated_sprite.frame == 0:
			_animated_sprite.frame = 1
		else:
			_animated_sprite.frame = 0
		#_animated_sprite.frame = 0
		#print(_animated_sprite.frame)
	#elif Input.is_action_pressed("ui_left"):
		##_animated_sprite.play("lr")
		#_animated_sprite.frame = 1
	#else:
		#_animated_sprite.stop()
