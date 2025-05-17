extends Node

# Track how many times the player has interacted with each NPC
var interaction_counts := {}

# Track relationship points for each NPC
var relationship_scores := {}
var ai_answer = ""
var ai_answer_positive = false
var ai_rate = 0
var npc_name = ""
var control_buttons = []

func _ready():
	var ask_help_button = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox/AskHelpButton")
	var gift_button = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox/GiftButton")
	control_buttons = [ask_help_button, gift_button]

func register_interaction(npc_name: String):
	interaction_counts[npc_name] = interaction_counts.get(npc_name, 0) + 1

func increase_relationship(npc_name: String, amount: int = 1):
	var npc_relationship_score = get_relationship(npc_name)
	relationship_scores[npc_name] = npc_relationship_score + amount
	print("New relationship score for %s is %d" %[npc_name, relationship_scores[npc_name]])
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
	
func disable_buttons():
	for button in control_buttons:
		if button != null:
			button.disabled = true
		
func enable_buttons():
	for button in control_buttons:
		if button != null:
			button.disabled = false
	
func give_gift(npc_name: String):
	var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox")
	var item_name = VillageContext.get_npc_wanted_gift(npc_name)
	if Inventory.has_item(item_name, 1):
		Inventory.remove_item(item_name, 1)
		VillageContext.reset_npc_wanted_gifts()
		var relationship_score = PlayerBehavior.get_relationship(npc_name)
		disable_buttons()
		AI.get_ai_dialogue({'npc_name': npc_name, 'interaction_type': 'gift', 'quest_type': item_name, 'relationship_score': relationship_score, 'ask_count': 0}, Callable(self, "_on_ai_gift_response"))
		dialogue_box.show_dialogue("%s is watching the %s you gave" % [npc_name,item_name])
	else:
		var main = get_tree().root.get_node("Main")
		dialogue_box.show_dialogue("%s: You don't have any %s to give me!" % [npc_name, item_name])
	
func ask_for_help(npc_name: String):
	var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox")
	if QuestManager.quest_active and QuestManager.quest_npc == npc_name:
		print(QuestManager.quest_npc_agreed)
		if QuestManager.quest_npc_agreed:
			QuestManager.progress_quest()
		else:
			var relationship_score = PlayerBehavior.get_relationship(npc_name)
			var npc_count = QuestManager.quest_npc_counts.get(npc_name, 0)
			disable_buttons()
			AI.get_ai_dialogue({'npc_name': npc_name, 'interaction_type': 'ask for help', 'quest_type': QuestManager.quest_type, 'relationship_score': relationship_score, 'ask_count': npc_count}, Callable(self, "_on_ai_help_response"))
			dialogue_box.show_dialogue(npc_name + " is thinking about your request.")
		# Check for quest completion
		if QuestManager.is_quest_complete():
			var complete_text = "Quest %s completed!" %[QuestManager.quest_type]
			dialogue_box.show_dialogue(complete_text)
			QuestManager.reset_quest()
	else:
		dialogue_box.show_dialogue("%s: It seems you don't have anything that needs my help." % [npc_name])

func think_of_chat(npc_name: String):
	var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox")
	if npc_name == "":
		dialogue_box.show_dialogue("Please select one character to chat")
		return
	disable_buttons()
	var relationship_score = PlayerBehavior.get_relationship(npc_name)
	AI.get_ai_dialogue({'npc_name': npc_name, 'interaction_type': 'think of chat', 'quest_type': QuestManager.quest_type, 'relationship_score': relationship_score, 'ask_count': 0}, Callable(self, "_on_ai_think_response"))
	
func _on_ai_think_response(ai_response):
	var option1Button = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox/ChatOptionsContainer/Option1Button")
	var option2Button = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox/ChatOptionsContainer/Option2Button")
	var option3Button = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox/ChatOptionsContainer/Option3Button")
	var option1 = ai_response.get("option 1")
	var option2 = ai_response.get("option 2")
	var option3 = ai_response.get("option 3")
	if option1 != null:
		option1Button.text = option1
		option1Button.visible = true
	if option2 != null:
		option2Button.text = option2
		option2Button.visible = true
	if option3 != null:
		option3Button.text = option3
		option3Button.visible = true
		
func _on_ai_chat_response(ai_response):
	var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox")
	ai_answer = ai_response.get("text")
	ai_rate = parse_int(ai_response.get("rate", 0))
	print(ai_answer, ai_rate)
	dialogue_box.show_dialogue(
		"%s: %s" % [VillageContext.get_currnet_npc(), ai_answer]
	)
	increase_relationship(npc_name, ai_rate)
	enable_buttons()
		
func chat_with_npc(question):
	var npc_name = VillageContext.get_currnet_npc()
	var relationship_score = PlayerBehavior.get_relationship(npc_name)
	AI.get_ai_dialogue({'npc_name': npc_name, 'interaction_type': 'chat', 'quest_type': question, 'relationship_score': relationship_score, 'ask_count': 0}, Callable(self, "_on_ai_chat_response"))
		
func select_chat_option(option_number):
	var option1Button = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox/ChatOptionsContainer/Option1Button")
	var option2Button = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox/ChatOptionsContainer/Option2Button")
	var option3Button = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox/ChatOptionsContainer/Option3Button")
	option1Button.visible = false
	option2Button.visible = false
	option3Button.visible = false
	match option_number:
		1:
			chat_with_npc(option1Button.text)
		2:
			chat_with_npc(option2Button.text)
		3:
			chat_with_npc(option3Button.text)

func parse_bool(value):
	if typeof(value) == TYPE_BOOL:
		return value
	if typeof(value) == TYPE_STRING:
		return value.to_lower() == "true"
	return false
	
func parse_int(value):
	if typeof(value) == TYPE_INT:
		return value
	if typeof(value) == TYPE_STRING:
		return int(value)
	return 0

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
	enable_buttons()
		
func _on_ai_gift_response(ai_response):
	var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox")
	ai_answer = ai_response.get("text")
	ai_rate = parse_int(ai_response.get("rate", 0))
	print(ai_answer, ai_rate)
	dialogue_box.show_dialogue(
		"%s: %s" % [VillageContext.get_currnet_npc(), ai_answer]
	)
	increase_relationship(npc_name, ai_rate)
	enable_buttons()
