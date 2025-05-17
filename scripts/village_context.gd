extends Node

var context: String = "Normal Day"

func set_context(new_context: String):
	context = new_context

func get_context() -> String:
	return context
