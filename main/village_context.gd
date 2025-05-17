extends Node

var context: String = "Normal Day"
var current_npc: String = ""
var npc_wanted_gifts: Dictionary = {}
var relationship_label = null

func _ready() -> void:
	relationship_label = get_tree().root.get_node("Main/CanvasLayer/RelationshipLabel")

func set_context(new_context: String):
	context = new_context

func set_current_npc(npc_name: String):
	current_npc = npc_name
	update_relationship_label()
	
func update_relationship_label(npc_name="", relationship_score=null):
	if npc_name == "":
		print("npc_name is null")
		npc_name = current_npc
	print("npc name: " + npc_name)
	if relationship_score == null:
		print("relationship_score is null")
		relationship_score = PlayerBehavior.get_relationship(current_npc)
	var new_label = "Current relationship score with %s: %d" %[npc_name, relationship_score]
	relationship_label.text = new_label
	print(new_label)

func get_currnet_npc() -> String:
	return current_npc
	
func unset_current_npc():
	current_npc = ""
	relationship_label.text = ""
	
func reset_npc_wanted_gifts():
	npc_wanted_gifts = {}
	
func get_npc_wanted_gift(npc_name):
	var random_gift = WorldConfig.get_random_item()
	var wanted_gift = npc_wanted_gifts.get(npc_name, random_gift)
	npc_wanted_gifts[npc_name] = wanted_gift
	return wanted_gift
