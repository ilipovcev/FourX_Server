extends Node

var network = NetworkedMultiplayerENet.new()
const SERVER_PORT = 1909
const MAX_PLAYERS = 4

var players: Array
var pls_map = {}
var GameMap: Map;

var matrix_map = []
var matrix_width = 23
var matrix_height = 13

var player_path_1 = []
var player_path_2 = []
var player_path_3 = []
var player_path_4 = []


func _ready():
	GameMap = Map.new();
	GameMap.LoadFromFile("MapAbout.json");
	
	var ms: Vector2 = GameMap.GetSize();
	var st: String;
	for i in range(ms.y):
		st = "[";
		for j in range(ms.x):
			st += GameMap.GetCell(j, i).GetType() + ", ";
		st += "]";
		ScreenText(st);
	
	var pl: Player = Player.new();
	pl.SetName("ilipa");
	
	GameMap.GetCell(2, 0).OnStepOn(pl);
	GameMap.GetCell(1, 0).OnStepOn(pl);
	GameMap.GetCell(1, 1).OnStepOn(pl);
	startServer()


func ScreenText(text):
	get_node("Console/ConsoleText").add_text(text)
	get_node("Console/ConsoleText").newline()
	

func GetPlayerById(PlId):
	return players[pls_map[PlId]];


func startServer():
	network.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(network)
	print("Server started")
	ScreenText("Server started")

	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")


func _Peer_Connected(id):
	print("User ", id, " connected");
	rpc_id(id, "OnMapLoaded", GameMap.to_string());
	
	
func _Peer_Disconnected(id):
	print("User ", id, " disconnected")
	ScreenText("User " + String(id) + " disconnected")
	var Player: Player = GetPlayerById(id);
	rpc("PlayerLeftGame", Player.GetName())
	players.erase(Player)


remote func RegPlayer(name):
	var idPlayer = get_tree().get_rpc_sender_id()
	var pl: Player = Player.new()
	pl.Id = idPlayer
	pl.SetName(name)
	players.append(pl)
	pls_map[pl.Id] = players.size()-1;

	rpc_id(idPlayer, "OnRegPlayer", pl.Id, pl.GetName(), pl.GetHealth());
	print("Players count: ", players.size())
	ScreenText("Players count: " + String(players.size()))
	for i in players:
		print(i.GetName())
	if players.size() == MAX_PLAYERS:
		PlayersDone()


remote func IsRoll():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var steps_number = rng.randi_range(1, 6)


remote func PlayerWin():
	var idPlayer = get_tree().get_rpc_sender_id()
	var Player = GetPlayerById(idPlayer);

	if Player.IsLoose == true:
		return
	
	Player.IsWin = true
	rpc("getWinner",  Player.Name)
	print("Player ", Player.Name, " is winner")
	ScreenText("Player " + Player.Name + " is winner")
	

func PlayersDone():
	print("All players connected")
	ScreenText("All players connected")
	#rpc("StartGame")
