extends Area2D

@export var npc_name: String = "Villager"
@export var color: Color = Color(1,1,1)

func _ready():
	add_to_group("NPCs")
	var label = $NameLabel
	if label == null:
		print("Label not found")
	else:
		label.text = npc_name
	$ColorRect.color = color
	print("Ready: ", npc_name)

func _on_npc_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		PlayerBehavior.register_interaction(npc_name)
		var main = get_tree().root.get_node("Main")
		var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/DialogueBox")
		

		# Check if this NPC is key for the quest
		if QuestManager.quest_active and QuestManager.quest_npc == npc_name:
			var relationship_score = PlayerBehavior.get_relationship(npc_name)
			var required
			print("Relationship score with %s is %d" % [npc_name, relationship_score])
			if relationship_score >= 3:
				QuestManager.progress_quest()
				PlayerBehavior.increase_relationship(npc_name, 1)
				dialogue_box.show_dialogue(
					"I'll help you gather wood! (Progress: %d/%d)" % [QuestManager.quest_progress, QuestManager.quest_required]
				)
			else:
				dialogue_box.show_dialogue("Sorry, I don't trust you enough to help with the storm.", self)
		else:
			dialogue_box.show_dialogue("Hello, I am " + npc_name + "!", self)
		
		# Check for quest completion
		if QuestManager.is_quest_complete():
			var complete_text = "Quest complete! Your house is safe from the storm."
			dialogue_box.show_dialogue(complete_text)
			QuestManager.reset_quest()

func give_gift(item_name: String):
	var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/DialogueBox")
	if Inventory.has_item(item_name, 1):
		Inventory.remove_item(item_name, 1)
		PlayerBehavior.increase_relationship(npc_name, 2)
		var main = get_tree().root.get_node("Main")
		dialogue_box.show_dialogue("Thank you for the %s! I like you more now." % item_name)
	else:
		var main = get_tree().root.get_node("Main")
		dialogue_box.show_dialogue("You don't have any %s to give me!" % item_name)
