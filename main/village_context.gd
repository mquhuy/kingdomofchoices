extends Node

var context: String = "Normal Day"
var current_npc: String = ""

func set_context(new_context: String):
	context = new_context

func set_current_npc(npc_name: String):
	current_npc = npc_name

func get_currnet_npc() -> String:
	return current_npc
	
func unset_current_npc():
	current_npc = ""
