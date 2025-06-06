extends Node2D
@onready var npc_scene = preload("res://characters/NPC.tscn")
@onready var item_scene = preload("res://items/Item.tscn")

var ITEM_SPAWN_CONFIGS = [
	ItemSpawnConfig.new(
		"Apple", "apple.png", 2, 3, 4,
		func(): return true
	),
	ItemSpawnConfig.new(
		"Flower", "flower.png", 1, 2, 5,
		func(): return true
	),
	ItemSpawnConfig.new(
		"Wood", "wood.png", 1, 2, 10,
		func(): return true
	)
]

func _ready():
	spawn_npc("Lira", "res://graphics/girl_stand.png", Vector2(450, 100))
	spawn_npc("Tomo", "res://graphics/blacksmith_stand.png", Vector2(1300, 550))
	spawn_npc("Anna", "res://graphics/granny_stand.png", Vector2(550, 500))
	
func check_and_spawn_needed_items():
	for item_conf in ITEM_SPAWN_CONFIGS:
		if not item_conf.spawn_condition.call():
			continue
		var name = item_conf.name
		var path = item_conf.path
		var needed_in_inventory = item_conf.needed_in_inventory
		var max_on_map = item_conf.max_on_map
		var in_inventory = Inventory.get_item_count(name)
		var on_map = count_items_on_map(name)
		if in_inventory < needed_in_inventory and on_map < max_on_map:
			spawn_item(name, path, get_random_valid_position())

func get_random_position():
	return Vector2(randi() % 600 + 50, randi() % 400 + 50)
	
func spawn_npc(name: String, path: String, pos: Vector2):
	var npc_instance = npc_scene.instantiate()
	npc_instance.npc_name = name
	npc_instance.position = pos
	npc_instance.set_sprite_texture(path)
	add_child(npc_instance)

	
func spawn_item(name: String, path: String, pos: Variant = null):
	var item = item_scene.instantiate()
	item.item_name = name
	# Load the texture from the given path
	var tex = load(path)
	
	# Assign texture to Sprite2D
	var sprite = item.get_node("ItemImg")
	sprite.texture = tex
	
	# Set position as before
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


func _on_start_quest_button_pressed() -> void:
	pass # Replace with function body.
