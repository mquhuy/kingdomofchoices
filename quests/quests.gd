extends Node

func _process(delta):
	var quest_status_label = get_tree().root.get_node("Main/CanvasLayer/QuestStatusLabel")
	if QuestManager.quest_active:
		quest_status_label.text = "%s Prep: %d/%d" % [QuestManager.quest_type, QuestManager.quest_progress, QuestManager.quest_required]
	else:
		quest_status_label.text = ""

func _on_start_quest_button_pressed() -> void:
	QuestManager.start_quest("festival time", "Anna", 10)
