extends Area2D

@export var item_name: String = "Apple"
@export var item_color: Color = Color.RED  # If using ColorRect
@export var despawn_time: float = 5.0 # Number of seconds before disappearing
var picked_up = false

func _ready():
	add_to_group("WorldItems")
	add_to_group("Item_" + item_name)
	start_despawn_timer(despawn_time)
	if has_node("ColorRect"):
		$ColorRect.color = item_color
	if has_node("ItemNameLabel"):
		$ItemNameLabel.text = item_name
		
func start_despawn_timer(seconds: float):
	$DespawnTimer.wait_time = seconds
	$DespawnTimer.start()

func _input_event(viewport, event, shape_idx):
	if not picked_up and event is InputEventMouseButton and event.pressed:
		picked_up = true
		Inventory.add_item(item_name, 1)
		var count = Inventory.get_item_count(item_name)
		print("Collected %s. Inventory %d" %[item_name, count])
		queue_free()


func _on_despawn_timer_timeout() -> void:
	queue_free()
