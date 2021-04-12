class_name Map

var CELL_TYPES: Dictionary = {
	"Cell": Cell,
	"CellDamage": CellDamage,
	"CellArmor": CellArmor,
};

var Matrix = [];
var Size: Vector2;

func GetSize():
	return Size;

func LoadFromJson(map: JSONParseResult):
	var res = map.result;
	print(res);
	
	Size = Vector2(res['Size'][0], res['Size'][1]);
	
	if res['Cells'].size() != res['Size'][0]:
		print("АШИПКА. Кривой размер карты.");
		return;
	
	Matrix.resize(res['Size'][0]);
	for i in range(res['Size'][0]):
		var row: Array;
		row.resize(res['Size'][1]);
		for j in range(res['Size'][1]):
			
			var s: String;
			if typeof(res['Cells'][i][j]) == TYPE_ARRAY:
				randomize();
				s = res['Cells'][i][j][randi() % res['Cells'][i][j].size()];
			else:
				s = res['Cells'][i][j];
				if !(s in CELL_TYPES):
					s = "Cell";
					
			row[j] = CELL_TYPES[s].new();
			row[j].SetCoords(i, j);
			
		Matrix[i] = row;
	
	print("Карта размером ", res['Size'][0], " на ", res['Size'][1], " загружена.");
	Init();

func LoadFromJsonStr(map: String):
	LoadFromJson(JSON.parse(map));

func LoadFromFile(filename: String):
	print("Чтение карты из файла ", filename);
	var file = File.new()
	file.open("res://"+filename, File.READ)
	LoadFromJsonStr(file.get_as_text());
	file.close()
	
func Init():
	print("Инициализация мира..."); 

func GetCell(i, j: int):
	return Matrix[i][j];
