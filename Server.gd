extends Node

var network = NetworkedMultiplayerENet.new()
const SERVER_PORT = 1909
const MAX_PLAYERS = 4

var players: Array
var pls_map = {}
var GameMap: Map;

func _ready():
	if !LoadMap():
		ScreenText("Can`t load map.");
		return;
	PrintMap();
	
	startServer();

func LoadMap():
	GameMap = Map.new();
	GameMap.ResetPlayer();
	return GameMap.LoadFromFile("MapAboutNew.json");

func PrintMap():
	var ms: Vector2 = GameMap.GetSize();
	var st: String;
	for i in range(ms.y):
		st = "[";
		for j in range(ms.x):
			st += GameMap.GetCell(j, i).GetType() + ", ";
		st += "]";
		ScreenText(st);

func ScreenText(text):
	get_node("Console/ConsoleText").add_text(text)
	get_node("Console/ConsoleText").newline()


func startServer():
	network.create_server(SERVER_PORT, MAX_PLAYERS);
	get_tree().set_network_peer(network);
	print("Server started");
	ScreenText("Server started");

	network.connect("peer_connected", self, "_Peer_Connected");
	network.connect("peer_disconnected", self, "_Peer_Disconnected");


func _Peer_Connected(id):
	print("User ", id, " connected");
	
	
func _Peer_Disconnected(id):
	print("User ", id, " disconnected");
	ScreenText("User " + String(id) + " disconnected");
	

func GetPlayerById(PlId):
	for i in players:
		pls_map[i.GetId()] = players.find(i);
		print("id: ", i.GetId(), ". index: ", players.find(i));
	return players[pls_map[PlId]];


remote func RegPlayer(name):
	var idPlayer = get_tree().get_rpc_sender_id()
	var pl: Player = Player.new()

	pl.SetId(idPlayer);
	pl.SetName(name);
	players.append(pl);
	pls_map[pl.GetId()] = players.size()-1;

	GameMap.SetPlayer(players.size()-1, pl);
	rpc_id(idPlayer, "OnMapLoaded", GameMap.to_string());
	pl = GameMap.GetPlayer(players.size()-1);
	players[players.size()-1] = pl;

	rpc("OnRegPlayer", pl.GetName(), pl.GetId(), pl.GetHealth(), pl.GetOrigin());

	print("Players count: ", players.size());
	ScreenText("Players count: " + String(players.size()));

	for i in players:
		print(i.GetName());
	if players.size() == MAX_PLAYERS:
		PlayersDone();


func get_players_state():
	var states = [];
	var i = 0;
	while i <= players.size()-1:
		states.append(GameMap.GetPlayerState(i));
		i += 1;
	print("Server state: ", states);
	return states;


remote func IsRoll():
	var rng = RandomNumberGenerator.new();
	rng.randomize();
	var steps_number = rng.randi_range(1, 6);
	var idPlayer = get_tree().get_rpc_sender_id()
	var pl: Player = GetPlayerById(idPlayer);
	var pl_index = players.find(pl);

	if GameMap.GetPlayerTurn(pl_index):
		GameMap.MovePlayer(pl_index, steps_number);
		rpc_id(idPlayer, "OnRoll", pl.GetOrigin(), steps_number, pl_index);

		if GameMap.IsPlayerDead(pl_index):
			print("Player ", pl_index, " is dead");
			pls_map.erase(pl.GetId());
			players.erase(pl);
			rpc("get_states", get_players_state());
			rpc_id(pl.GetId(), "on_dead");
			rpc("on_player_dead", pl.GetId());
			send_players_turn_state();
			do_roll();
			return;

		if GameMap.IsPlayerWin(pl_index):
			rpc("get_states", get_players_state());
			rpc_id(pl.GetId(), "on_win");
			rpc("on_player_win", pl.GetId());
			rpc("stop_game");
			GameMap.ResetPlayer();
			get_tree().set_network_peer(null);
			return;
	else: 
		print("Ход другого игрока!");

	rpc("get_states", get_players_state());
	send_players_turn_state();
	do_roll();


func do_roll():
	rpc("on_roll");
	
func send_players_turn_state():
	for pl in players:
		rpc_id(pl.GetId(), "is_turn", pl.GetTurn());


func PlayersDone():
	var rng = RandomNumberGenerator.new();
	rng.randomize();
	GameMap.SetPlayerTurn(rng.randi() % players.size());

	print("All players connected")
	ScreenText("All players connected")
	
	rpc("StartGame", get_players_state());
	rpc("get_states", get_players_state());
	send_players_turn_state();
	do_roll();
