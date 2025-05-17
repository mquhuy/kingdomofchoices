extends Node

var quest_active := false
var quest_type := ""
var quest_progress := 0
var quest_required := 3
var quest_npc := "" # Which NPC is key to this quest
var quest_instruction := ""
var quest_npc_agreed = false
var quest_npc_counts = {}

func start_quest(_type: String, _npc: String, _required: int = 3):
	quest_active = true
	quest_npc_agreed = false
	quest_type = _type.capitalize()
	quest_npc = _npc
	quest_progress = 0
	quest_required = _required
	quest_instruction = "%s. Ask %s for help" % [quest_type, quest_npc]
	VillageContext.set_context(quest_type)
	var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox")
	dialogue_box.show_dialogue(QuestManager.quest_instruction)
	var start_quest_button = get_tree().root.get_node("Main/CanvasLayer/Control/StartQuestButton")
	start_quest_button.disabled = true

func progress_quest():
	PlayerBehavior.increase_relationship(quest_npc, -1)
	if quest_active:
		quest_progress += 1
	if is_quest_complete():
		return
	quest_npc = WorldConfig.get_random_character()
	quest_instruction = "%s. Ask %s for help" % [quest_type, quest_npc]
	var npc_count = quest_npc_counts.get(quest_npc, 0)
	quest_npc_counts[quest_npc] = npc_count

func is_quest_complete():
	return quest_active and quest_progress >= quest_required

func reset_quest():
	quest_active = false
	quest_type = ""
	quest_progress = 0
	quest_required = 0
	quest_npc = ""
	quest_npc_counts = {}
	var start_quest_button = get_tree().root.get_node("Main/CanvasLayer/Control/StartQuestButton")
	start_quest_button.disabled = false
