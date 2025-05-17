class_name ItemSpawnConfig

var name: String
var color: Color
var needed_in_inventory: int
var max_on_map: int
var despawn_time: float
var spawn_condition: Callable

func _init(name, color, needed_in_inventory, max_on_map, despawn_time, spawn_condition):
	self.name = name
	self.color = color
	self.needed_in_inventory = needed_in_inventory
	self.max_on_map = max_on_map
	self.despawn_time = despawn_time
	self.spawn_condition = spawn_condition
