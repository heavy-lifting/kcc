extends Label

var velocity: Vector2 = Vector2.ZERO
var gravity: float = 500.0  # Pixels per second squared
var fade_speed: float = 2.0 # How fast it disappears

func _ready() -> void:
	# Give it a random upward and outward burst
	velocity.x = randf_range(-150.0, 150.0)
	velocity.y = randf_range(-200.0, -350.0)
	
	# Optional: Give it a slight random rotation twist
	pivot_offset = size / 2
	var twist_tween = create_tween()
	twist_tween.tween_property(self, "rotation", randf_range(-0.5, 0.5), 0.4)

func _process(delta: float) -> void:
	# Apply gravity to velocity, then move the label
	velocity.y += gravity * delta
	position += velocity * delta
	
	# Fade out over time
	modulate.a -= fade_speed * delta
	
	# Free memory once it's invisible
	if modulate.a <= 0:
		queue_free()
