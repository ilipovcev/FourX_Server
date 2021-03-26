extends Node
 
var network = NetworkedMultiplayerENet.new()
const SERVER_PORT = 1909
const MAX_PLAYERS = 4


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
