extends Node

var network = NetworkedMultiplayerENet.new()
const SERVER_PORT = 1909
const MAX_PLAYERS = 4

var players: Array;
var pls_map = {};

func _ready():
	startServer()


func GetPlayerById(PlId):
	return players[pls_map[PlId]];


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
	var Player = GetPlayerById(id);
	rpc("PlayerLeftGame", Player.Name)
	players.erase(Player)


remote func RegPlayer(name):
	var idPlayer = get_tree().get_rpc_sender_id()
	var RegisterPlayer = PlayerDataServer.new()
	RegisterPlayer.Id = idPlayer
	RegisterPlayer.Name = name
	RegisterPlayer.HP = 4
	RegisterPlayer.IsWin = false
	RegisterPlayer.IsTurn = false
	RegisterPlayer.IsLoose = false
	players.append(RegisterPlayer)
	pls_map[RegisterPlayer.Id] = players.size()-1;

	rpc_id(idPlayer, "OnRegPlayer", RegisterPlayer.Id, RegisterPlayer.Name, RegisterPlayer.HP);
	rpc_id(idPlayer, "PlayerSpawnPoint", players.find(RegisterPlayer)+1)

	print("Players count: ", players.size())
	for i in players:
		print(i.Name)
	if players.size() == MAX_PLAYERS:
		PlayersDone()


remote func IsRoll():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var steps_number = rng.randi_range(1, 6)

	var idPlayer = get_tree().get_rpc_sender_id()
	var Player = GetPlayerById(idPlayer);

	if Player.IsLoose == true:
		return
	
	if Player.IsTurn == true:
		rpc_id(idPlayer, "SetRoll", -1)
		return
	
	Player.IsTurn = true
	rpc_id(idPlayer, "SetRoll", steps_number)


remote func DecHP():
	var idPlayer = get_tree().get_rpc_sender_id()
	var Player = GetPlayerById(idPlayer);

	if Player.IsLoose == true:
		return
	
	Player.HP -= 1
	Player.IsTurn = false
	
	if Player.HP <= 0:
		Player.IsLoose = true
		rpc("OnPlayerLoose", Player.Name, Player.Id)
		rpc_id(idPlayer, "LooseGame")
		return

	print("Player ", Player.Name, " HP: ", Player.HP)
	rpc_id(idPlayer, "SetPlayerHP", Player.HP)


remote func IncHP():
	var idPlayer = get_tree().get_rpc_sender_id()
	var Player = GetPlayerById(idPlayer);

	if Player.IsLoose == true:
		return
	
	Player.HP += 1
	Player.IsTurn = false
	
	print("Player ", Player.Name, " HP: ", Player.HP)
	rpc_id(idPlayer, "SetPlayerHP", Player.HP)


remote func PlayerWin():
	var idPlayer = get_tree().get_rpc_sender_id()
	var Player = GetPlayerById(idPlayer);

	if Player.IsLoose == true:
		return
	
	Player.IsWin = true
	rpc("getWinner",  Player.Name)
	print("Player ", Player.Name, " is winner")
	

func PlayersDone():
	print("All players connected")
	#rpc("StartGame")
