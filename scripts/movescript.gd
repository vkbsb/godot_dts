
extends Node2D

export var AnimationString = "MoveRight"
export var ReverseWhen = "LeftWall"
export var PlayWhen = "RightWall"
# member variables here, example:
# var a=2
# var b="textvar"
var ActiveSpikeList = IntArray()
var spikesToShow = 3

func _ready():
	# Initalization here
	pass

func updateDifficulty(gameScore):
	#determine the number of spikes to show based on current score.
	var maxCount = 9
	if (gameScore  < maxCount):
		spikesToShow = gameScore
	if( gameScore < 3 ):
		spikesToShow = 3

func resetSpikeList():
	for i in ActiveSpikeList:
		get_children()[i].get_node("./Spike/anim").play(AnimationString, -1, -1, true)
	ActiveSpikeList.resize(0)
	
func _on_Player_body_enter( body ):
	if body.get_name() == ReverseWhen:
		#if the left wall is collided we retract the left wall spikes, and 
		for i in ActiveSpikeList:
			get_children()[i].get_node("./Spike/anim").play(AnimationString, -1, -1, true)
		ActiveSpikeList.resize(0)
	elif body.get_name() == PlayWhen:
		for i in range(spikesToShow):
			var index = randi() % get_child_count()
			ActiveSpikeList.push_back(index)
			get_children()[index].get_node("./Spike/anim").play(AnimationString)
