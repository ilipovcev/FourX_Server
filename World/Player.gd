extends Node
class_name Player

var Health: int = 4;
var Nick: String = "Unnamed";
var Id: int;
var Origin: Vector2;
var Turn: bool = false;
var death: bool = false;
var win: bool = false;

func OnTakeDamage(dmg: int):
	Health -= dmg;
	print("Игрок ", Nick, " получил ", dmg, " урона. (", Health, "HP)");
	if Health <= 0:
		SetDeath();

func OnTakeHealth(hp: int):
	Health += hp;
	print("Игрок ", Nick, " получил ", hp, " здоровья. (", Health, "HP)" );

func SetWin():
	win = true;
	print("Игрок ", Nick, " выиграл.");

func IsWin():
	return win;
	
func SetDeath():
	death = true;
	print("Игрок ", Nick, " умер.");

func IsDeath():
	return death;

func SetName(name: String):
	Nick = name;

func GetName():
	return Nick;

func SetHealth(hp):
	Health = hp;

func GetHealth():
	return Health;
	
func SetOrigin(vec: Vector2):
	Origin = vec;
	print("Игрок ", Nick, " передвинут на координаты ", vec);
	
func GetOrigin():
	return Origin;

func SetId(id):
	Id = id;

func GetId():
	return Id;

func SetTurn(is_turn: bool):
	Turn = is_turn;

func GetTurn():
	return Turn;
