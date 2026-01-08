extends Control

@onready var score_label = $ScoreLabel

func _process(delta):
	score_label.text = "Score: " + str(ScoreManager.get_score())
