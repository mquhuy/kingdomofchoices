extends Panel

func show_dialogue(text: String):
	var dialogue_text = $DialogueText
	dialogue_text.text = text
	show()
	
func hide_dialogue():
	hide()

func _on_give_gift_pressed() -> void:
	var current_npc = VillageContext.get_currnet_npc()
	if current_npc != "":
		PlayerBehavior.give_gift(current_npc)
	else:
		show_dialogue("No one to give a gift to")

func _on_ask_help_button_pressed() -> void:
	var current_npc = VillageContext.get_currnet_npc()
	if current_npc != "":
		PlayerBehavior.ask_for_help(current_npc)
	else:
		show_dialogue("Please select a character to ask for help")

func _on_tip_button_pressed() -> void:
	if QuestManager.quest_instruction != "":
		show_dialogue(QuestManager.quest_instruction)


func _on_chat_button_pressed() -> void:
	var current_npc = VillageContext.get_currnet_npc()
	PlayerBehavior.think_of_chat(current_npc)


func _on_option_1_button_pressed() -> void:
	PlayerBehavior.select_chat_option(1)

func _on_option_2_button_pressed() -> void:
	PlayerBehavior.select_chat_option(2)

func _on_option_3_button_pressed() -> void:
	PlayerBehavior.select_chat_option(3)
