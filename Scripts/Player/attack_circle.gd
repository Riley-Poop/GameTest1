# attack_circle.gd
extends Node2D

var radius = 200
var duration = 0.5
var time_passed = 0
var circle_color = Color(1, 0, 0, 0.5)

func _process(delta):
	time_passed += delta
	update()
	
	# Fade out
	var alpha = 1.0 - (time_passed / duration)
	circle_color.a = alpha
	
	if time_passed >= duration:
		queue_free()

func _draw():
	draw_circle(Vector2.ZERO, radius, circle_color)
