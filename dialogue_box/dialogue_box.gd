extends Panel

var current_npc = null

func _ready():
	print("In _ready DialogueText node: ", $DialogueText)

func show_dialogue(text: String, npc_ref = null):
	print("In show_dialogue DialogueText node: ", $DialogueText)
	var dialogue_text = $DialogueText
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
