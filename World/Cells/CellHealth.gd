extends Cell
class_name CellHealth

func OnStepOn(pl: Player):
	print("Игрок ", pl.GetName()," наступил лечащаю клетку ", Coords, ".");
	pl.OnGetHealth();

func GetType():
	return "heal";
