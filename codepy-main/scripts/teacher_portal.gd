extends Control

# Basic teacher portal script
func _ready() -> void:
	print("Teacher portal ready")
	
	# Create a simple label
	var label = Label.new()
	label.text = "Teacher Portal"
	label.position = Vector2(100, 100)
	add_child(label)
