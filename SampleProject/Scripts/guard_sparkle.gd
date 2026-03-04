extends CPUParticles2D
class_name GuardSparkle
static var tight_guard_sparkle: bool = false

# Becomes more red with less guard health
func calculate_sparkle_color():
	var guard_health = min(Global.player.stats.Stats["Guard"], 2)
	if not tight_guard_sparkle:
		self_modulate = Color(3-(guard_health)*0.75, 0.5+(guard_health)*0.75, 0.5+(guard_health)*0.5)
	else:
		self_modulate = Color(1,1,3)
		tight_guard_sparkle = false
