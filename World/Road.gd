class_name Road

var Cells: Array;

func AddStep(cl: Cell):
	Cells.push_back(cl);

func GetStep(index: int):
	return Cells[index];
	
func MoveFromIndex(pl: Player, index: int, rng: int):
	if rng < 1:
		return -1;
	if index < 0 || index+rng >= Cells.size():
		return -1;
	
	Cells[index].OnStepOut(pl);
	for i in range(1, rng):
		Cells[index+i].OnStepOver(pl);
	Cells[index+rng].OnStepOn(pl);
	pl.SetOrigin(Cells[index+rng].GetCoords());
	
	return index;

func MoveFromVec(pl: Player, from: Vector2, rng: int):
	return MoveFromIndex(pl, FindCellByVec(from), rng);

func Move(pl: Player, rng: int):
	return MoveFromVec(pl, pl.GetOrigin(), rng);

func FindCellByVec(vec: Vector2):
	for i in range(Cells.size()):
		if Cells[i].GetCoords() == vec:
			return i;
	return -1;
