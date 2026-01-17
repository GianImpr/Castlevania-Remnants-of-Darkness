extends CPUParticles2D

# Becomes more red with less guard health
func calculate_sparkle_color():
	var guard_health = min(Global.player.stats.Stats["Guard"], 2)
	self_modulate = Color(3-(guard_health)*0.75, 0.5+(guard_health)*0.75, 0.5+(guard_health)*0.5)
