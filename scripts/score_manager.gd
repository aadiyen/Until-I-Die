extends Node

var score = 0
var high_score = 0
var score_label: Label
var high_score_label: Label

func _ready():
	await ensure_ui_loaded()
	load_high_score()
	update_score_label()
	update_high_score_label()
	get_tree().paused = true

	
	

func ensure_ui_loaded():
	var max_wait_frames = 60
	var frames_waited = 0

	while (not score_label or not high_score_label) and frames_waited < max_wait_frames:
		score_label = get_node_or_null("../UI2/GameUI/ScoreLabel")
		high_score_label = get_node_or_null("../UI2/GameUI/HighScoreLabel")
		
		if score_label and high_score_label:
			break
		
		await get_tree().process_frame
		frames_waited += 1
	
	if not score_label:
		push_error("ScoreLabel not found after waiting!")
	if not high_score_label:
		push_error("HighScoreLabel not found after waiting!")


func add_score(value):
	score += value
	update_score_label()

	if score > high_score:
		high_score = score
		update_high_score_label()
		save_high_score()


func reset_score():
	score = 0
	update_score_label() 


func get_score():
	return score


func _on_start_button_pressed():
	
	get_node("../UI2/GameUI/Instructions").hide()
	get_node("../UI2/GameUI/StartButton").hide()
	get_node("../UI2/GameUI/TitleLabel").hide()
	get_tree().paused = false
	

func _on_restart_button_pressed():
	var score = 0
	ScoreManager.reset_score()
	get_tree().paused = false
	get_tree().reload_current_scene()


func save_high_score():
	var file = FileAccess.open("user://high_score.save", FileAccess.WRITE)
	file.store_line(str(high_score))
	file.close()


func load_high_score():
	if FileAccess.file_exists("user://high_score.save"):
		var file = FileAccess.open("user://high_score.save", FileAccess.READ)
		high_score = int(file.get_line())
		file.close()


func update_score_label():
	if score_label:
		score_label.text = "Score: %d" % score


func update_high_score_label():
	if high_score_label:
		high_score_label.text = "High Score: %d" % high_score
 
func reset_high_score_temp():### high score reset
	high_score = 0
	update_high_score_label()
