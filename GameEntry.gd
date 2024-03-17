extends Control

var player_scene_path = "res://scenes/Player.tscn"
var player = load("res://scenes/Player.tscn")
onready var multiplayer_config_ui = $Connector
onready var ip_input_field = $Connector/Server_ip
onready var network = get_node("/root/Net")

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")

func _on_Join_server_pressed():
	var ip_address = ip_input_field.text
	if ip_address != "":
		multiplayer_config_ui.hide()
		network.server_url = "ws://" + ip_address + ":8080" 
		network.connect_to_server()

func _on_Create_server_pressed():
	multiplayer_config_ui.hide()
	yield(get_tree().create_timer(0.1), "timeout")
	change_scene_to_main()

func change_scene_to_main():
	get_tree().change_scene("res://scenes/Main.tscn")

func _player_connected(id):
	print(str(id) + " Connected to server.")
	
	instance_player(id)

func _connected_to_server():
	change_scene_to_main()
	

func instance_player(id):
	var player_instance = Global.instance_node_at_location(player, Players, Vector2(rand_range(0,1920), rand_range(500,600)))
	player_instance.name = str(id)
	player_instance.set_network_master(id)
