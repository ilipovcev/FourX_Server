class_name Player

var Health: int = 10;
var Nick: String = "Unnamed";
var Armor = 0;

func OnTakeDamage(dmg: int):
	if Armor > 0:
		Armor -= 1;
		print("Игрок ", Nick, " потерялединицу брони. (", Armor, "AP)");
		return;
	
	Health -= dmg;
	print("Игрок ", Nick, " получил ", dmg, " урона. (", Health, "HP)");
	if Health <= 0:
		OnDeath();
		
func AddArmor(armor: int):
	Armor += armor;
	
func OnDeath():
	print("Игрок ", Nick, " умер.");

func SetName(name: String):
	Nick = name;

func GetName():
	return Nick;

func GetHealth():
	return Health;
