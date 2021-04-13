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
	GameMap.LoadFromFile("TestMap.json");
	
	var ms: Vector2 = GameMap.GetSize();
	var st: String;
	for i in range(ms.y):
		st = "[";
		for j in range(ms.x):
			st += GameMap.GetCell(j, i).GetType() + ", ";
		st += "]";
		ScreenText(st);
	
	var pl: Player = Player.new();
	pl.SetName("ArKaNeMaN");
	
	GameMap.GetCell(2, 0).OnStepOn(pl);
	GameMap.GetCell(1, 0).OnStepOn(pl);
	GameMap.GetCell(1, 1).OnStepOn(pl);
	
	return;
	
	for y in range(matrix_height):
		matrix_map.append([])
		matrix_map[y].resize(matrix_width)

	PlayerPath()
	MapGenerator()
	startServer()


func UpdatePlayer1Path(x, y):
	var cell_class = load("res://PathCoord.gd")
	var Cell = cell_class.new()

	Cell.X = x
	Cell.Y = y
	matrix_map[Cell.Y][Cell.X] = Cell
	player_path_1.push_back(Cell)

func PlayerPath():
	UpdatePlayer1Path(0,6)
	UpdatePlayer1Path(1,6)
	UpdatePlayer1Path(1,7)
	UpdatePlayer1Path(2,7)
	UpdatePlayer1Path(2,7)
	UpdatePlayer1Path(2,8)
	UpdatePlayer1Path(2,9)
	UpdatePlayer1Path(3,9)
	UpdatePlayer1Path(4,9)
	UpdatePlayer1Path(4,10)
	UpdatePlayer1Path(5,10)
	UpdatePlayer1Path(6,10)
	UpdatePlayer1Path(6,9)
	UpdatePlayer1Path(6,8)
	UpdatePlayer1Path(6,7)
	UpdatePlayer1Path(7,7)
	UpdatePlayer1Path(8,7)
	UpdatePlayer1Path(9,7)
	UpdatePlayer1Path(9,6)
	UpdatePlayer1Path(10,6)


func MapGenerator():
	var cell_class = load("res://PathCoord.gd")
	var Cell = cell_class.new()
	var matrix_map_visual = []

	for y in range(matrix_height):
		matrix_map_visual.append([])
		matrix_map_visual[y].resize(matrix_width)
	
	ScreenText(String(range(matrix_width)))
	for y in range(matrix_height):
		for x in range(matrix_width):
			if matrix_map[y][x]:
				matrix_map_visual[y][x] = 1
				continue
			matrix_map_visual[y][x] = 0	

			if y == 6 && x == 11:
				matrix_map_visual[y][x] = 5
		ScreenText(String(y) + String(matrix_map_visual[y]))

	for y in range(matrix_height):
		for x in range(matrix_width):
			if matrix_map[y][x]:
				matrix_map[y][x].IsPath = true
				print("Path at: ", x, " ", y)
				continue
			Cell.X = x
			Cell.Y = y
			matrix_map[y][x] = Cell	

			if y == 6 && x == 11:
				Cell.X = x
				Cell.Y = y
				Cell.IsWin = true
				matrix_map[y][x] = Cell


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
	ScreenText("Players count: " + String(players.size()))
	for i in players:
		print(i.Name)
	if players.size() == MAX_PLAYERS:
		PlayersDone()


remote func IsRoll():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var steps_number = rng.randi_range(1, 6)

	var idPlayer = get_tree().get_rpc_sender_id()
	var Player = GetPlayerById(idPlayer)
	
	if Player.IsTurn == true or Player.IsLoose == true:
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
	ScreenText("Player " + Player.Name + " HP: " + String(Player.HP))
	rpc_id(idPlayer, "SetPlayerHP", Player.HP)


remote func IncHP():
	var idPlayer = get_tree().get_rpc_sender_id()
	var Player = GetPlayerById(idPlayer);

	if Player.IsLoose == true:
		return
	
	Player.HP += 1
	Player.IsTurn = false
	
	print("Player ", Player.Name, " HP: ", Player.HP)
	ScreenText("Player " + Player.Name + " HP: " + String(Player.HP))
	rpc_id(idPlayer, "SetPlayerHP", Player.HP)


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
