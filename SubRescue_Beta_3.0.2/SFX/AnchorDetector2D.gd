class_name AnchorDetector2D

extends Area2D

# Emitted when entering an anchor area.
signal anchor_detected(anchor)
# Emitted after exiting all anchor areas.
signal anchor_detached

func _on_AnchorDetector2D_area_entered(area):
	emit_signal("anchor_detected", area)


func _on_AnchorDetector2D_area_exited(area):
	var _areas: Array = get_overlapping_areas()
	# To do so, we check that's there's but one overlapping area left and that it's
	# the one passed to this callback function.
	emit_signal("anchor_detached")
