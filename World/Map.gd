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
var Players: Array;
var rng = RandomNumberGenerator.new();

func GenerateRoads(map):
	var cells_array = ["CellDamage", "CellHealth"];
	randomize();
	map['Cells'][10][6] = 'CellWin';
	for i in range(Size.x):
		for j in range(Size.y):
			for e in range(map['Roads'].size()):
				for a in range(map['Roads'][e].size()-1):
					if i == map['Roads'][e][a][0] && j == map['Roads'][e][a][1]:
						map['Cells'][i][j] = cells_array[rng.randi_range(0, cells_array.size()-1)];
						#print(map['Cells'][i][j], " on ", map['Roads'][e][a])
	
	for i in map['Roads'][3].size():
		print(map['Cells'][map['Roads'][3][i][0]][map['Roads'][3][i][1]], " on ", map['Roads'][3][i]);

func ConvertMatrixToList(map):
	var adjList = [];
	for i in range(Size.x):
		adjList.append([]);
		adjList[i].resize(Size.y);
		for j in range(Size.y):
			if map['Cells'][i][j]:
				adjList[i].append(j);

	#print(adjList[0]);
	#print(adjList[1]);
	#print(adjList[2]);
	return adjList;
				

func LoadFromJson(map):
	Size = Vector2(map['Size'][0], map['Size'][1]);
	
	if map['Cells'].size() != Size.x:
		print("АШИПКА. Кривой размер карты.");
		return false;
	
	Matrix.resize(Size.x);
	GenerateRoads(map);
	for i in range(Size.x):
		if map['Cells'][i].size() != Size.y:
			print("АШИПКА. Кривой размер карты.");
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
	
	var RoadsCount = map['Roads'].size();
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
	print("Чтение карты из файла ", filename);
	var file = File.new();
	file.open("res://"+filename, File.READ);
	var res: bool = LoadFromJsonStr(file.get_as_text());
	file.close();
	return res;

func Init():
	print("Карта размером ", Size.x, " на ", Size.y, " загружена.");
	print("Инициализация мира...");


func GetSize():
	return Size;

func GetCell(i, j: int):
	return Matrix[i][j];

func GetCellByVec(vec: Vector2):
	return Matrix[vec.x][vec.y];


func GetRoad(index: int):
	return Roads[index];

func MovePlayer(index: int, rng: int):
	return GetRoad(index).Move(GetPlayer(index), rng);

func GetPlayerState(player_index: int):
	var pl = GetPlayer(player_index);
	var player_state = [pl.GetName(), pl.GetId(), pl.GetOrigin(), pl.GetHealth(), player_index];
	return player_state;

func SetPlayerTurn(player_index: int):
	GetPlayer(player_index).SetTurn(true);

func GetPlayerTurn(player_index: int):
	var pl = GetPlayer(player_index);
	if pl.GetTurn():
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
		RemovePlayer(player_index);
		return true;
	return false;

func IsPlayerWin(player_index: int):
	var pl = GetPlayer(player_index);
	if pl.IsWin():
		RemovePlayer(player_index);
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

func RemovePlayer(index: int):
	GetPlayerTurn(index);
	Players.remove(index);


func to_string():
	return JSON.print(jMap);

func UTIL_ArrToVec(a: Array):
	return Vector2(a[0], a[1]);
