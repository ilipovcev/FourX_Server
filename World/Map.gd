class_name Map

var CELL_TYPES: Dictionary = {
	"Cell": Cell,
	"CellDamage": CellDamage,
	"CellHealth": CellHealth,
	"CellWin": CellWin,
};

var Matrix = [];
var Size: Vector2;
var jMap;
var Roads: Array;
var RoadsCount;
var Players: Array;
var rng = RandomNumberGenerator.new();
var players_count;

func JSON_roads(filename: String):
	var file = File.new();
	file.open("res://RoadsJSON/"+filename, File.READ);
	var json_road = JSON.parse(file.get_as_text()).result;
	file.close();
	return json_road;

func SetRoads(map):
	var pl_1_filename = "Player1_"+String(rng.randi_range(1,2))+".json";
	var pl_1_json = JSON_roads(pl_1_filename)
	map['Roads'].push_back(pl_1_json['Road']);

	var pl_2_filename = "Player2_"+String(rng.randi_range(1,2))+".json";
	var pl_2_json = JSON_roads(pl_2_filename)
	map['Roads'].push_back(pl_2_json['Road']);

	var pl_3_filename = "Player3_"+String(rng.randi_range(1,2))+".json";
	var pl_3_json = JSON_roads(pl_3_filename)
	map['Roads'].push_back(pl_3_json['Road']);

	var pl_4_filename = "Player4_"+String(rng.randi_range(1,2))+".json";
	var pl_4_json = JSON_roads(pl_4_filename)
	map['Roads'].push_back(pl_4_json['Road']);

func GenerateRoads(map):
	var cells_array = ["CellDamage", "CellHealth"];
	randomize();
	SetRoads(map);
	map['Cells'][10][5] = 'CellWin';
	for i in range(Size.x):
		for j in range(Size.y):
			for e in range(map['Roads'].size()):
				for a in range(1, map['Roads'][e].size()-1):
					if i == map['Roads'][e][a][0] && j == map['Roads'][e][a][1]:
						map['Cells'][i][j] = cells_array[rng.randi_range(0, cells_array.size()-1)];
						#print(map['Cells'][i][j], " on ", map['Roads'][e][a])
	
	for i in map['Roads'][0].size():
		print(map['Cells'][map['Roads'][0][i][0]][map['Roads'][0][i][1]], " on ", map['Roads'][0][i]);


func LoadFromJson(map):
	Size = Vector2(map['Size'][0], map['Size'][1]);
	print("x: ", Size.x)
	print("y: ", Size.y)
	
	if map['Cells'].size() != Size.x:
		print("Error");
		return false;
	
	Matrix.resize(Size.x);
	GenerateRoads(map);
	for i in range(Size.x):
		if map['Cells'][i].size() != Size.y:
			print("Error");
			return false;
		
		var row: Array = [];
		row.resize(Size.y);

		for j in range(Size.y):
			var s: String;
			if typeof(map['Cells'][i][j]) == TYPE_ARRAY:
				randomize();
				s = map['Cells'][i][j][randi() % map['Cells'][i][j].size()];
			else:
				s = map['Cells'][i][j];
				if !(s in CELL_TYPES):
					s = "Cell";
					
			map['Cells'][i][j] = s;
			row[j] = CELL_TYPES[s].new();
			row[j].SetCoords(i, j);
		
		Matrix[i] = row;
	
	RoadsCount = map['Roads'].size();
	Roads.resize(RoadsCount);
	Players.resize(RoadsCount);
	for i in range(RoadsCount):
		var road: Road = Road.new();
		for j in range(map['Roads'][i].size()):
			road.AddStep(GetCellByVec(UTIL_ArrToVec(map['Roads'][i][j])));
		Roads[i] = road;
	
	jMap = map;
	Init();
	
	return true;

func LoadFromJsonStr(map: String):
	return LoadFromJson(JSON.parse(map).result);

func LoadFromFile(filename: String):
	print("???????????? ?????????? ???? ?????????? ", filename);
	var file = File.new();
	file.open("res://"+filename, File.READ);
	var res: bool = LoadFromJsonStr(file.get_as_text());
	file.close();
	return res;

func Init():
	print("?????????? ???????????????? ", Size.x, " ???? ", Size.y, " ??????????????????.");
	print("?????????????????????????? ????????...");


func GetSize():
	return Size;

func GetCell(i, j: int):
	return Matrix[i][j];

func GetCellByVec(vec: Vector2):
	return Matrix[vec.x][vec.y];


func GetRoad(index: int):
	return Roads[index];

func MovePlayer(index: int, steps_number: int):
	print("???????????? ", index, " ???????????? ?????????? ", steps_number);
	return GetRoad(index).Move(GetPlayer(index), steps_number);

func GetPlayerState(player_index: int):
	var pl: Player = GetPlayer(player_index);
	var player_state = [pl.GetName(), pl.GetId(), pl.GetOrigin(), pl.GetHealth(), player_index];
	return player_state;

func SetPlayerTurn(player_index: int):
	GetPlayer(player_index).SetTurn(true);

func GetPlayerTurn(player_index: int):
	var pl = GetPlayer(player_index);
	if pl.GetTurn():
		print("?????? ???????????? ", player_index);
		player_index += 1;
		if player_index > Players.size() - 1:
			player_index = 0;
		var pl_next = GetPlayer(player_index);
		pl_next.SetTurn(true);
		pl.SetTurn(false);
		return true;
	else:
		return false;


func IsPlayerDead(player_index: int):
	var pl = GetPlayer(player_index);
	if pl.IsDeath():
		RemovePlayer(pl);
		return true;
	return false;

func IsPlayerWin(player_index: int):
	var pl = GetPlayer(player_index);
	if pl.IsWin():
		return true;
	return false;


func GetPlayer(index: int):
	return Players[index];

func SetPlayer(index: int, pl: Player):
	Players[index] = pl;
	pl.SetOrigin(GetRoad(index).GetStep(0).GetCoords());

func ResetPlayer():
	Players.clear();
	Players.resize(Roads.size());

func RemovePlayer(pl: Player):
	var pl_index = Players.find(pl);
	Players.erase(pl);
	Roads.remove(pl_index);
	print("Removed. Size: ", Players.size());

func PlayerDisconnected(index: int):
	Players.remove(index);
	Players.resize(4);
	print("Removed. Size: ", Players.size());
	

func to_string():
	return JSON.print(jMap);

func UTIL_ArrToVec(a: Array):
	return Vector2(a[0], a[1]);
