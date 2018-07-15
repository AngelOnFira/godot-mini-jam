extends Control

var health = 4;

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func TakeDamage():
	match health:
		4:
			$"Fourth/AnimationPlayer".play("HeartEmpty")
		3:
			$"Third/AnimationPlayer".play("HeartEmpty")
		2:
			$"Second/AnimationPlayer".play("HeartEmpty")
		1:
			$"First/AnimationPlayer".play("HeartEmpty")
	health -= 1;

func TakeHealing():
	match health:
		3:
			$"Fourth/AnimationPlayer".play("HeartFill")
		2:
			$"Third/AnimationPlayer".play("HeartFill")
		1:
			$"Second/AnimationPlayer".play("HeartFill")
		0:
			$"First/AnimationPlayer".play("HeartFill")
	health += 1;