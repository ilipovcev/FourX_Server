class_name Cell

export var Coords: Vector2;

func SetCoords(x, y):
	Coords = Vector2(x, y);

# Наступил
func OnStepOn(pl: Player):
	print("Игрок ", pl.GetName(), " наступил на клетку ", Coords, ".");

# Переступил
func OnStepOver(pl: Player):
	print("Игрок ", pl.GetName(), " переступил клетку ", Coords, ".");

# Встал с клетки
func OnStepOut(pl: Player):
	print("Игрок ", pl.GetName(), " ушёл с клетки ", Coords, ".");

func GetType():
	return "empty";
