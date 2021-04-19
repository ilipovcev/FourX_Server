extends Cell
class_name CellWin

func OnStepOn(pl: Player):
  pl.OnWin();

func OnStepOver(pl: Player):
  pl.OnWin();

func GetType():
  return "win"
