extends Node

var quest_active := false
var quest_type := ""
var quest_progress := 0
var quest_required := 3
var quest_npc := "" # Which NPC is key to this quest

func start_quest(_type: String, _npc: String, _required: int = 3):
	quest_active = true
	quest_type = _type
	quest_npc = _npc
	quest_progress = 0
	quest_required = _required

func progress_quest():
	if quest_active:
		quest_progress += 1

func is_quest_complete():
	return quest_active and quest_progress >= quest_required

func reset_quest():
	quest_active = false
	quest_type = ""
	quest_progress = 0
	quest_required = 0
	quest_npc = ""
