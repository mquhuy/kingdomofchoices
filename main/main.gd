extends Node2D
@onready var npc_scene = preload("res://characters/NPC.tscn")
@onready var item_scene = preload("res://items/Item.tscn")

var ITEM_SPAWN_CONFIGS = [
	{
		"name": "Apple",
		"color": Color.RED,
		"needed_in_inventory": 2,
		"max_on_map": 3,
		"despawn_time": 4,
		"spawn_condition": func() -> bool: return true
	},
	{
		"name": "Flower",
		"color": Color.HOT_PINK,
		"needed_in_inventory": 1,
		"max_on_map": 2,
		"despawn_time": 5,
		"spawn_condition": func() -> bool: return true
	},
	{
		"name": "Wood",
		"color": Color.SADDLE_BROWN,
		"needed_in_inventory": 1,
		"max_on_map": 2,
		"despawn_time": 10,
		"spawn_condition": func() -> bool: return QuestManager.quest_active and QuestManager.quest_type == "storm"
	}
]

func _ready():
	print("npc_scene =", npc_scene)
	spawn_npc("Lira", "res://graphics/girl_stand.png", Vector2(100, 100))
	spawn_npc("Tomo", "res://graphics/blacksmith_stand.png", Vector2(300, 100))
	spawn_npc("Anna", "res://graphics/granny_stand.png", Vector2(200, 250))
	
func check_and_spawn_needed_items():
	for item_conf in ITEM_SPAWN_CONFIGS:
		if not item_conf["spawn_condition"].call():
			continue
		var name = item_conf["name"]
		var color = item_conf["color"]
		var needed_in_inventory = item_conf["needed_in_inventory"]
		var max_on_map = item_conf["max_on_map"]
		var in_inventory = Inventory.get_item_count(name)
		var on_map = count_items_on_map(name)
		if in_inventory < needed_in_inventory and on_map < max_on_map:
			spawn_item(name, color, get_random_valid_position())

func get_random_position():
	return Vector2(randi() % 600 + 50, randi() % 400 + 50)
	
	
func spawn_npc(name: String, path: String, pos: Vector2):
	var npc_instance = npc_scene.instantiate()
	print("npc_instance =", npc_instance)

	print(npc_instance, npc_instance.get_script())
	npc_instance.npc_name = name
	npc_instance.position = pos
	npc_instance.set_sprite_texture(path)
	add_child(npc_instance)

	
func spawn_item(name: String, color: Color, pos: Variant = null):
	var item = item_scene.instantiate()
	item.item_name = name
	item.item_color = color
	if typeof(pos) == TYPE_VECTOR2:
		item.position = pos
	else:
		item.position = get_random_valid_position()
	add_child(item)

func count_items_on_map(item_name: String) -> int:
	var group_name = "Item_" + item_name
	return get_tree().get_nodes_in_group(group_name).size()

func get_random_valid_position(min_distance: float = 64.0, max_tries: int = 30) -> Vector2:
	var area_min = WorldConfig.WORLD_MIN
	var area_max = WorldConfig.WORLD_MAX
	var rng = RandomNumberGenerator.new()
	var pos = get_random_position()
	for i in max_tries:
		pos = Vector2(
			rng.randi_range(int(area_min.x), int(area_max.x)),
			rng.randi_range(int(area_min.y), int(area_max.y))
		)
		if is_position_valid(pos, min_distance):
			return pos
	# If no valid found, return last tried
	return pos

func is_position_valid(pos: Vector2, min_distance: float) -> bool:
	# Avoid NPCs
	for npc in get_tree().get_nodes_in_group("NPCs"):
		if npc.position.distance_to(pos) < min_distance:
			return false
	# Avoid Player (if you have one)
	if has_node("Player"):
		var player = get_node("Player")
		if player.position.distance_to(pos) < min_distance:
			return false
	# Avoid other world items
	for item in get_tree().get_nodes_in_group("WorldItems"):
		if item.position.distance_to(pos) < min_distance:
			return false
	return true

func _on_item_need_check_timer_timeout() -> void:
	check_and_spawn_needed_items()
