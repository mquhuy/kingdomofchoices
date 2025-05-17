extends Node

const WORLD_MIN = Vector2(0, 0)
const WORLD_MAX = Vector2(3000, 2000)
const character_names = ["Anna", "Tomo", "Lira"]
const quest_names = ["festival time", "storm recovery", "spring cleaning", "midnight hunt"]

var rng = RandomNumberGenerator.new()

func get_random_character():
	rng.randomize()
	return WorldConfig.character_names[rng.randi_range(0, WorldConfig.character_names.size() - 1)]
	
func get_random_quest():
	rng.randomize()
	return quest_names[rng.randi_range(0, quest_names.size() - 1)]
	
func get_random_number(from, to):
	rng.randomize()
	return rng.randi_range(from, to)
