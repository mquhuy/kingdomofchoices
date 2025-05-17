extends Node

func _process(delta):
	if QuestManager.quest_active:
		$QuestStatusLabel.text = "Storm Prep: %d/%d" % [QuestManager.quest_progress, QuestManager.quest_required]
	else:
		$QuestStatusLabel.text = ""

func _on_start_quest_button_pressed() -> void:
	QuestManager.start_quest("storm", "Tomo", 3)
	VillageContext.set_context("Storm Coming!")
	$StartQuestButton.disabled = true
	$QuestStatusLabel.text = "Storm quest started! Ask Tomo for help."
