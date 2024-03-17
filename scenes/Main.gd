extends Node2D


var player_scene = preload("res://scenes/Player.tscn")
var players = {}
var operation_queue = []

func _ready():
	var network = get_node("/root/Net")
	network.connect("operation_received", self, "receive_operation")

func instance_player(id: int):
	var player_instance = player_scene.instance()
	add_child(player_instance)
	player_instance.global_position = Vector2(rand_range(0, 1920), rand_range(500, 600))
	player_instance.name = str(id)
	players[id] = player_instance

func _process(delta: float):
	resolve_operations()

func resolve_operations():
	operation_queue.sort_custom(self, "_sort_operations_by_timestamp")
	for operation in operation_queue:
		if players.has(operation.player_id):
			players[operation.player_id].apply_operation(operation)
	operation_queue.clear()

func receive_operation(operation: Dictionary):
	operation_queue.append(operation)

func _sort_operations_by_timestamp(a, b):
	return a.timestamp < b.timestamp
