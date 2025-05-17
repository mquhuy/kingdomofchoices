extends Node

var items := {}

func add_item(item_name: String, amount: int = 1):
	items[item_name] = items.get(item_name, 0) + amount

func remove_item(item_name: String, amount: int = 1):
	var count = get_item_count(item_name)
	if count < amount:
		print("Not enough %s. Has %d, required %d" %[item_name, count, amount])
	else:
		items[item_name] -= amount
		if items[item_name] <= 0:
			items.erase(item_name)

func has_item(item_name: String, amount: int = 1) -> bool:
	return items.get(item_name, 0) >= amount

func get_item_count(item_name: String) -> int:
	return items.get(item_name, 0)
