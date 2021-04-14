class_name Player

var Health: int = 10;
var Nick: String = "Unnamed";
var Id: int;

func OnTakeDamage(dmg: int):
	Health -= dmg;
	print("Игрок ", Nick, " получил ", dmg, " урона. (", Health, "HP)");
	if Health <= 0:
		OnDeath();

func OnGetHealth():
	Health += 1;
	print("Игрок ", Nick, " получил + 1хп. (", Health, "HP)" );

func OnWin():
	print("Игрок ", Nick, " выиграл.")
	
func OnDeath():
	print("Игрок ", Nick, " умер.");

func SetName(name: String):
	Nick = name;

func GetName():
	return Nick;

func GetHealth():
	return Health;
