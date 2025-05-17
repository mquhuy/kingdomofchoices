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
