extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func show(level, timer):
	$LabelMain.text = "Level " + str(level + 1)
	$LabelTimer.text = int_to_timestring(int(timer))
	$Curtain.show()
	$LabelTimer.show()
	$LabelMain.show()

func hide():
	$LabelContinue.hide()
	$LabelMain.hide()
	$LabelTimer.hide()
	$Curtain.hide()

func continue_():
	$LabelContinue.show()

func int_to_timestring(t: int):
	var hours = "%0*d" % [2, t / 3600]
	var minutes = "%0*d" % [2, (t % 3600) / 60]
	var seconds = "%0*d" % [2, ((t % 3600) % 60)]
	return "%s:%s:%s" % [hours, minutes, seconds]
