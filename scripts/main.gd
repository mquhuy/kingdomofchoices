extends Node2D

@onready var npc_scene = preload("res://characters/NPC.tscn")

func _ready():
	spawn_npc("Lira", Color.ORANGE, Vector2(100, 100))
	spawn_npc("Tomo", Color.GREEN, Vector2(300, 100))
	spawn_npc("Anna", Color.BLUE, Vector2(200, 250))
	
func spawn_npc(name: String, color: Color, pos: Vector2):
	var npc_instance = npc_scene.instantiate()
	npc_instance.npc_name = name
	npc_instance.color = color
	npc_instance.position = pos
	add_child(npc_instance)
	
func _process(delta):
	if QuestManager.quest_active:
		$QuestStatusLabel.text = "Storm Prep: %d/%d" % [QuestManager.quest_progress, QuestManager.quest_required]
	else:
		$QuestStatusLabel.text = ""


func _on_start_quest_button_pressed() -> void:
	QuestManager.start_quest("storm", "Tomo", 3)
	VillageContext.set_context("Storm Coming!")
	$StartQuestButton.disabled = true
	$QuestStatusLabel.text = "Storm quest started! Ask Tomo for help."
