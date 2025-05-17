extends Area2D

@export var npc_name: String = "Villager"
@export var color: Color = Color(1,1,1)

func _ready():
	var label = $NameLabel
	if label == null:
		print("Label not found")
	else:
		label.text = npc_name
	$ColorRect.color = color
	print("Ready: ", npc_name)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		print("Hello, I am " + npc_name + "!")
		var main = get_tree().root.get_node("Main")
		var dialogue_box = main.get_node("DialogueBox")
		dialogue_box.show_dialogue("Hello, I am " + npc_name + "!")
