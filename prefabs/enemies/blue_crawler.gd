extends CharacterBody2D


func _on_vision_cone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Player detected but do not chase yet.
		# Throw a raycast first.
		# If the raycast hits a wall (layer 1) first then there's a block in the view.
		# DO NOT CHASE THE PLAYER.
		# But if the raycast hits the player_body (layer 7) then switch to chase state.
		# Chase the player until the raycast gets cut off by a visual obstruction.
		# Before losing interest (going back to patrol mode).
		# Look left and right first. Jump on the spot if necessary.
		# If the player went back to the vision and got detected. Chase back.
		# Else return to patrol mode.
		pass
