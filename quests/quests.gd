extends Node

func _process(delta):
	var quest_status_label = get_tree().root.get_node("Main/CanvasLayer/QuestStatusLabel")
	if QuestManager.quest_active:
		quest_status_label.text = "%s Prep: %d/%d" % [QuestManager.quest_type, QuestManager.quest_progress, QuestManager.quest_required]
	else:
		quest_status_label.text = ""

func _on_start_quest_button_pressed() -> void:
	var character_name = WorldConfig.get_random_character()
	var quest_name = WorldConfig.get_random_quest()
	var quest_goal = WorldConfig.get_random_number(5, 15)
	QuestManager.start_quest(quest_name, character_name, quest_goal)
