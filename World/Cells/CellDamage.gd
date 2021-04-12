extends Cell
class_name CellDamage

func OnStepOn(pl: Player):
	print("Игрок ", pl.GetName()," наступил на повреждающую клетку ", Coords, ".");
	pl.OnTakeDamage(2);

func GetType():
	return "damage";
