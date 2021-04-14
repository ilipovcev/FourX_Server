class_name Player

var Health: int = 10;
var Nick: String = "Unnamed";
var Id: int;
var Origin: Vector2;

func OnTakeDamage(dmg: int):
	Health -= dmg;
	print("Игрок ", Nick, " получил ", dmg, " урона. (", Health, "HP)");
	if Health <= 0:
		OnDeath();

func OnTakeHealth(hp: int):
	Health += hp;
	print("Игрок ", Nick, " получил ", hp, " здоровья. (", Health, "HP)" );

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
	
func SetOrigin(vec: Vector2):
	Origin = vec;
	# print("Игрок передвинут на координаты ", vec);
	
func GetOrigin():
	# На клиенте надо плавно перемещать
	return Origin;
