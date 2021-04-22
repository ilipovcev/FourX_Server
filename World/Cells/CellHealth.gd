extends Cell
class_name CellHealth

func OnStepOn(pl: Player):
	print("Игрок ", pl.GetName()," наступил лечащаю клетку ", Coords, ".");
	pl.OnTakeHealth(1);

func GetType():
	return "health";
