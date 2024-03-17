extends Node

signal operation_received(operation)
var ws_client = WebSocketClient.new()
var server_url = "ws://127.0.0.1:8080" 

func _ready():
	ws_client.connect("connection_established", self, "_on_connection_established")
	ws_client.connect("connection_error", self, "_on_connection_error")
	ws_client.connect("connection_closed", self, "_on_connection_closed")
	ws_client.connect("data_received", self, "_on_data_received")

func _process(delta: float):
	ws_client.poll()

func connect_to_server():
	ws_client.connect_to_url(server_url)

func _on_connection_established(protocol: String):
	print("Connected to server with protocol: ", protocol)
	emit_signal("connection_established")

func _on_connection_error():
	print("Failed to connect to server.")
	emit_signal("connection_failed")

func _on_connection_closed(cleanly: bool):
	print("Connection closed ", "cleanly" if cleanly else "with error.")
	emit_signal("connection_failed")

func _on_data_received():
	var message = ws_client.get_peer(1).get_packet().get_string_from_utf8()
	emit_signal("operation_received", parse_json(message))

func send_operation(operation: Dictionary):
	var message = to_json(operation)
	ws_client.get_peer(1).put_packet(message.to_utf8())

func to_json(dict: Dictionary) -> String:
	return JSON.print(dict)

func parse_json(json_string: String) -> Dictionary:
	var result = JSON.parse(json_string)
	if result.error == OK:
		return result.result
	else:
		return {}


