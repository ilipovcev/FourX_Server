extends Cell
class_name CellWin

func OnStepOn(pl: Player):
  pl.SetWin();

func OnStepOver(pl: Player):
  pl.SetWin();

func GetType():
  return "win"
