
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
	
func _on_npc_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		PlayerBehavior.register_interaction(npc_name)
		VillageContext.set_current_npc(npc_name)
		var main = get_tree().root.get_node("Main")
		var dialogue_box = get_tree().root.get_node("Main/CanvasLayer/Control/DialogueBox")
		dialogue_box.show_dialogue("%s: Hello, I am %s !" % [npc_name, npc_name])
