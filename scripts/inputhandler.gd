
extends RigidBody2D

var gameStarted = false
var gameOver = false
var sprNode
var xSpeed = 150
var btnDown = false
var scoreLabel
var gameScore = 0
var birdAnim
var particleSystem

func _ready():
	# Initalization here
	set_fixed_process(true)
	set_process_input(true)
	sprNode = get_node(NodePath("Sprite"))
	scoreLabel = get_node("../ScoreLabel")
	scoreLabel.hide()
	particleSystem = get_node("Sprite/Trail")
	
	#cache the animation player for bird fly animations.
	birdAnim = get_node("Sprite/BirdAnimations")
	
	#setting up signals supported by the object.
	var argument = { "score" : TYPE_INT }
	var ArgumentArray = Array()
	ArgumentArray.append(argument)
	add_user_signal("ScoreChanged", ArgumentArray)
	
	#signal handling for bg color change based on score.
	connect("ScoreChanged", get_node("../backgroundColor"), "updateColor")
	#signal handling for difficulty spike based on gameScore
	connect("ScoreChanged", get_node("../RightWall/SpikeController"), "updateDifficulty")
	connect("ScoreChanged", get_node("../LeftWall/SpikeController"), "updateDifficulty")
	

func restartGame():
	set_linear_velocity(Vector2(0, 0))
	set_angular_velocity(0)
	set_rot(0)
	set_pos(Vector2(153, 202))
	set_mode(RigidBody2D.MODE_CHARACTER)
	sprNode.set_flip_h(false)
	gameStarted  = false
	gameOver = false
	var spikeController = get_node("../RightWall/SpikeController")
	spikeController.resetSpikeList()
	spikeController = get_node("../LeftWall/SpikeController")
	spikeController.resetSpikeList()
	get_node("../Label").show()
	scoreLabel.hide()
	birdAnim.play("fly")
	gameScore = 0
	
	#Changing the sprite randomly to use a different bird everytime we restart.
	var arr = StringArray()
	arr.push_back("res://images/b1_sprite.png")
	arr.push_back("res://images/b2_sprite.png")
	arr.push_back("res://images/f1_sprite.png")
	var indx = randi() % arr.size()
	var res = load(arr[indx])
	sprNode.set_texture(res)

func _fixed_process(delta):
	if gameStarted == false:
		if get_pos().y > 200:
			apply_impulse(Vector2(0, 0), Vector2(0, -100))
	
#	if btnDown == true:
#		impulse_based_solution()
#		
	#if the game is over and the velocity of the object is very low we
	#reset the game.
	if get_linear_velocity().y > 0:
		particleSystem.set_emitting(false)
		
	if gameOver == true \
		and abs(get_linear_velocity().x) < 1 \
		and abs(get_linear_velocity().y) < 1:
		
		print("Game Restart Logic")
		restartGame()

func impulse_based_solution():
	if gameOver == true:
		return
		
	if gameStarted == true:
		apply_impulse(Vector2(0, 0), Vector2(0, -2000))
	else:
		set_linear_velocity(Vector2(-xSpeed, -100))
		get_node("../Label").hide()
		scoreLabel.show()
		scoreLabel.set_text(str(gameScore))
		gameStarted = true
	btnDown = false

func _input(event):
	if gameOver == true:
		return
		
	if(event.type ==  InputEvent.MOUSE_BUTTON):
		btnDown = event.is_pressed()
		if btnDown == true:
			birdAnim.play("up")
			impulse_based_solution()
			particleSystem.set_emitting(true)
		
func _on_Player_body_enter( body ):
	if gameOver:
		return
		
	var name = body.get_name()
	if name == "LeftWall":
		print("Turn Right")
		sprNode.set_flip_h(true)
		#set_linear_velocity(Vector2(xSpeed, get_linear_velocity().y))
		apply_impulse(Vector2(0, 0), Vector2(xSpeed, 0))
		gameScore += 1
		scoreLabel.set_text(str(gameScore))
		emit_signal("ScoreChanged", gameScore)
		particleSystem.set_pos(Vector2(-15, 1))
		pass
	elif name == "RightWall":
		print("Turn Left")
		sprNode.set_flip_h(false)
		#set_linear_velocity(Vector2(-xSpeed, get_linear_velocity().y))
		apply_impulse(Vector2(0, 0), Vector2(-xSpeed, 0))
		gameScore += 1
		scoreLabel.set_text(str(gameScore))
		emit_signal("ScoreChanged", gameScore)
		particleSystem.set_pos(Vector2(15, 1))
		pass
	elif name == "Roof" or name == "Floor" or body.get_groups().find("Spike") > -1:
		set_mode(RigidBody2D.MODE_RIGID)
		birdAnim.play("die")
		set_angular_velocity(100)
		gameOver = true
		pass
	#restrict the max speed to 200, we keep incrementing wheever the score is a multiple of 10.
	if gameScore > 0 and gameScore % 25 == 0:
		xSpeed += 20
		if(xSpeed > 200):
			xSpeed = 200

