extends TileMapLayer

# High fade values make the shake end incredibly quickly (try 40 to 60)
@export var shake_fade: float = 50.0 

var shake_strength: float = 0.0
@onready var original_position: Vector2 = position

func _process(delta: float) -> void:
	if shake_strength > 0:
		# Rapidly diminish the strength value
		shake_strength = max(shake_strength - (shake_fade * delta), 0)
		
		# Squaring the strength creates a sharp drop-off (decay curve)
		# This gives it an aggressive snap-back feel
		var current_power = shake_strength * shake_strength
		
		position = original_position + Vector2(
			randf_range(-current_power, current_power),
			randf_range(-current_power, current_power)
		)
	else:
		position = original_position

# Call this from your OSC script when the message hits
func trigger_shake() -> void:
	# A lower starting number here behaves like a massive burst 
	# because we are squaring it in the loop (e.g., 6.0 * 6.0 = 36 pixel offset)
	shake_strength = 6.0 
