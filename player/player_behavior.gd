extends Node

# Track how many times the player has interacted with each NPC
var interaction_counts := {}

# Track relationship points for each NPC
var relationship_scores := {}
var ai_answer = ""
var ai_answer_positive = false
var npc_name = ""

func register_interaction(npc_name: String):
	interaction_counts[npc_name] = interaction_counts.get(npc_name, 0) + 1

func increase_relationship(npc_name: String, amount: int = 1):
	var npc_relationship_score = get_relationship(npc_name)
	relationship_scores[npc_name] = npc_relationship_score + amount
	relationship_scores[npc_name] = clamp(relationship_scores[npc_name], 0, 20)

func get_relationship(npc_name: String) -> int:
	return relationship_scores.get(npc_name, 3)  # Default relationship is 3

func get_favorite_npc():
	var max_interactions = -1
	var favorite = ""
	for name in interaction_counts.keys():
		if interaction_counts[name] > max_interactions:
			max_interactions = interaction_counts[name]
			favorite = name
	return favorite if max_interactions > 0 else ""
	
func give_gift(npc_name: String):
	var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox")
	var item_name = VillageContext.get_npc_wanted_gift(npc_name)
	if Inventory.has_item(item_name, 1):
		Inventory.remove_item(item_name, 1)
		increase_relationship(npc_name, 2)
		var main = get_tree().root.get_node("Main")
		dialogue_box.show_dialogue("Thank you for the %s! I like you more now." % item_name)
	else:
		var main = get_tree().root.get_node("Main")
		dialogue_box.show_dialogue("You don't have any %s to give me!" % item_name)
	
func ask_for_help(npc_name: String):
	var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox")
	if QuestManager.quest_active and QuestManager.quest_npc == npc_name:
		print(QuestManager.quest_npc_agreed)
		if QuestManager.quest_npc_agreed:
			QuestManager.progress_quest()
		else:
			var relationship_score = PlayerBehavior.get_relationship(npc_name)
			var npc_count = QuestManager.quest_npc_counts.get(npc_name, 0)
			AI.get_ai_dialogue({'npc_name': npc_name, 'interaction_type': 'ask for help', 'quest_type': QuestManager.quest_type, 'relationship_score': relationship_score, 'ask_count': npc_count}, Callable(self, "_on_ai_help_response"))
			dialogue_box.show_dialogue(npc_name + " is thinking about your request.")
		# Check for quest completion
		if QuestManager.is_quest_complete():
			var complete_text = "Quest %s completed!" %[QuestManager.quest_type]
			dialogue_box.show_dialogue(complete_text)
			QuestManager.reset_quest()
	else:
		dialogue_box.show_dialogue("%s: It seems you don't have anything that needs my help." % [npc_name])

func parse_bool(value):
	if typeof(value) == TYPE_BOOL:
		return value
	if typeof(value) == TYPE_STRING:
		return value.to_lower() == "true"
	return false

func _on_ai_help_response(ai_response):
	var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox")
	ai_answer = ai_response.get("text")
	ai_answer_positive = parse_bool(ai_response.get("agree", "false"))
	print(ai_answer, ai_answer_positive)
	dialogue_box.show_dialogue(
		"%s: %s" % [VillageContext.get_currnet_npc(), ai_answer]
	)
	if ai_answer_positive:
		QuestManager.progress_quest()
