extends Node


var http_request: HTTPRequest

var control_buttons = []

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))

var _callback = null

func get_ai_dialogue(data: Dictionary, callback: Callable, model: String="deepseek-chat"):
	var url = "http://0.0.0.0:8000/api/ai_dialogue"
	var headers = ["Content-Type: application/json"]
	data["model"] = model
	var json_body = JSON.stringify(data)
	_callback = callback
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if err != OK:
		print("AI request error: ", err)

func _on_request_completed(result, response_code, headers, body):
	var ai_response = response_code
	if response_code == 200:
		var response_json = JSON.parse_string(body.get_string_from_utf8())
		ai_response = response_json
	if _callback != null:
		_callback.call(ai_response)
