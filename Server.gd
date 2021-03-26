extends Node


var PlayerData : = preload("res://PlayerData.gd") as Script;
tool

var network = NetworkedMultiplayerENet.new()
const SERVER_PORT = 1909
const MAX_PLAYERS = 4

var players: Array;

func _ready():
	startServer()
	

func startServer():
	network.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(network)
	print("Server started")

	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")


func _Peer_Connected(id):
	print("User ", id, " connected")

	
func _Peer_Disconnected(id):
	print("User ", id, " disconnected")


remote func RegPlayer(name):
	var idPlayer = get_tree().get_rpc_sender_id()
	var player = PlayerData.new();
	player.peer_id = idPlayer;
	player.nick = name;
	players.push_front(player);
	var playerStr = [idPlayer, name]
	rpc("OnRegPlayer", playerStr);
	
