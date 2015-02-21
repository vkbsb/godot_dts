
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
export(Color) var bgColor
var arr
var index = 0

func _ready():
	# Initalization here
	arr = Array()
	arr.append(Color(0.9, 0, 0.8, 1))
	arr.append(Color(0.8, 0.8, 0, 1))
	arr.append(Color(1, 1, 1, 1))
	pass

func updateColor():
	index += 1
	index %= arr.size()
	bgColor = arr[index]
	update()
	
func _draw():
	draw_rect(get_parent().get_item_rect(), bgColor)

