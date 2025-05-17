extends Node

func _process(delta):
	var quest_status_label = get_tree().root.get_node("Main/CanvasLayer/QuestStatusLabel")
	if QuestManager.quest_active:
		quest_status_label.text = "%s Prep: %d/%d" % [QuestManager.quest_type, QuestManager.quest_progress, QuestManager.quest_required]
	else:
		quest_status_label.text = ""

func _on_start_quest_button_pressed() -> void:
	var quest_names = ["festival time", "storm recovery", "spring cleaning", "midnight hunt"]
	var character_names = ["Anna", "Tomo", "Lira", "Ben"]
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var quest_name = quest_names[rng.randi_range(0, quest_names.size() - 1)]
	var character_name = character_names[rng.randi_range(0, character_names.size() - 1)]
	var quest_goal = rng.randi_range(5, 20)
	QuestManager.start_quest(quest_name, character_name, quest_goal)
