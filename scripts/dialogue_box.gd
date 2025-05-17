extends Panel

@onready var dialogue_text = $DialogueText

func show_dialogue(text: String):
	dialogue_text.text = text
	show()
	
func hide_dialogue():
	hide()
