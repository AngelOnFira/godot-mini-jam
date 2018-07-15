extends Control

var coins

func _ready():
	coins = 0
	pass

func _process(delta):
	$"Label".text = str(coins)
	pass

func gain_coins(amt):
	coins += amt
