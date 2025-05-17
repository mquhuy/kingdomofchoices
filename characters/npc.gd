extends Area2D
@export var npc_name: String = "Villager"
@export var color: Color = Color(1,1,1)
var ai_answer = ""
var ai_answer_positive = false

func _ready():
	add_to_group("NPCs")
	var label = $NameLabel
	if label == null:
		print("Label not found")
	else:
		label.text = npc_name

	var figure = $Figure
	
	print("Ready: ", npc_name)
	
func set_sprite_texture(path: String):
	# Extract the file name (e.g., "tomo_sprite.png")
	var file_name = path.get_file()
	# Remove the extension to get the node name (e.g., "tomo_sprite")
	var node_name = file_name.get_basename()
	# Try to get the Sprite2D node with that name
	var sprite = $Figure
	if sprite:
		sprite.texture = load(path)
	else:
		push_error("Sprite2D node named '%s' not found in NPC scene!" % node_name)
	
func _on_ai_response(ai_response):
	var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/DialogueBox")
	ai_answer = ai_response.get("text")
	ai_answer_positive = ai_response.get("positive", false)
	dialogue_box.show_dialogue(
		"%s: %s" % [npc_name, ai_answer]
	)
	if ai_answer_positive:
		PlayerBehavior.increase_relationship(npc_name, 1)
		QuestManager.quest_npc_agreed = true

func _on_npc_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		PlayerBehavior.register_interaction(npc_name)
		var main = get_tree().root.get_node("Main")
		var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/DialogueBox")
		
		# Check if this NPC is key for the quest
		if QuestManager.quest_active and QuestManager.quest_npc == npc_name:
			if QuestManager.quest_npc_agreed:
				QuestManager.progress_quest()
			else:
				var relationship_score = PlayerBehavior.get_relationship(npc_name)
				ai_answer = ""
				AI.get_ai_dialogue("As the NPC %s, answer to player request for help with preparing for %s. 
				The relationship score between your character and the player is %d/20" %[npc_name, QuestManager.quest_type, relationship_score], Callable(self, "_on_ai_response"))
				dialogue_box.show_dialogue(npc_name + " is thinking about your request.", self)
		else:
			dialogue_box.show_dialogue("%s: Hello, I am %s !" % [npc_name, npc_name], self)
		
		# Check for quest completion
		if QuestManager.is_quest_complete():
			var complete_text = "Quest complete!"
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
