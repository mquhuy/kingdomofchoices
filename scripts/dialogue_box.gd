extends Panel

@onready var dialogue_text = $DialogueText
var current_npc = null

func show_dialogue(text: String, npc_ref = null):
	dialogue_text.text = text
	show()
	current_npc = npc_ref
	
func hide_dialogue():
	hide()


func _on_give_gift_pressed() -> void:
	if current_npc:
		var item_to_give = "Apple"
		current_npc.give_gift(item_to_give)
	else:
		show_dialogue("No one to give a gift to")
