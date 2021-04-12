extends Cell
class_name CellArmor

func OnStepOn(pl: Player):
	pl.AddArmor(1);

func GetType():
	return "armor";
