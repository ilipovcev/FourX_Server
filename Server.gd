extends Node

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
	var playerStr = [idPlayer, name]

	var RegisterPlayer = PlayerDataServer.new()
	RegisterPlayer.PlayerId = idPlayer
	RegisterPlayer.PlayerName = name
	RegisterPlayer.PlayerHP = 4
	RegisterPlayer.PlayerIsWin = false
	players.append(RegisterPlayer)

	rpc_id(idPlayer, "OnRegPlayer", playerStr);

	
remote func PlayerStatsChanged(HP):
	var idPlayer = get_tree().get_rpc_sender_id()
	var FindPlayer = PlayerDataServer.new()

	FindPlayer.PlayerId = idPlayer
	var indexPlayer = players.find(FindPlayer.PlayerId)
	players[indexPlayer].PlayerHP = HP
	
	print("Player ", players[indexPlayer].PlayerName, " HP: ", players[indexPlayer].PlayerHP)

	
