extends Node

# Track how many times the player has interacted with each NPC
var interaction_counts := {}

# Track relationship points for each NPC
var relationship_scores := {}

func register_interaction(npc_name: String):
	interaction_counts[npc_name] = interaction_counts.get(npc_name, 0) + 1

func increase_relationship(npc_name: String, amount: int = 1):
	relationship_scores[npc_name] = relationship_scores.get(npc_name, 5) + amount
	relationship_scores[npc_name] = clamp(relationship_scores[npc_name], 0, 10)

func get_relationship(npc_name: String) -> int:
	return relationship_scores.get(npc_name, 5)  # Default relationship is 5

func get_favorite_npc():
	var max_interactions = -1
	var favorite = ""
	for name in interaction_counts.keys():
		if interaction_counts[name] > max_interactions:
			max_interactions = interaction_counts[name]
			favorite = name
	return favorite if max_interactions > 0 else ""
