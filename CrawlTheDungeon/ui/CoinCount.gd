extends Control

var coins

func _ready():
	coins = 0
	$"Label".text = str(coins)

func gain_coins(amt):
	coins += amt
	$"Label".text = str(coins)
