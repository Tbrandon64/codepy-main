extends Node

## Thumbnail Generator - Creates promotional 800x400 images
## Usage: Call generate_thumbnail() to create promo images

func generate_thumbnail_image() -> Image:
	var image = Image.create(800, 400, false, Image.FORMAT_RGB8)
	
	# Create gradient background (purple to black)
	for y in range(400):
		for x in range(800):
			var progress = float(y) / 400.0
			var purple = Color(0.6, 0.0, 0.8, 1.0)
			var black = Color(0.0, 0.0, 0.0, 1.0)
			var color = purple.lerp(black, progress)
			image.set_pixel(x, y, color)
	
	return image

func draw_text_on_image(image: Image, text: String, x: int, y: int, font_size: int, color: Color) -> void:
	# Note: Godot 4.x doesn't have easy built-in text rendering to images
	# Use a CanvasItem instead or pre-render with an external tool
	# This is a placeholder showing the concept
	pass

func save_thumbnail(path: String = "user://thumbnail.png") -> void:
	var image = generate_thumbnail_image()
	image.save_png(path)
	print("Thumbnail saved to: ", path)

# Alternative: Use CanvasItem to render and screenshot
class ThumbnailRenderer:
	extends CanvasItem
	
	func _ready() -> void:
		draw_gradient_bg()
		draw_title_text()
		draw_subtext()
	
	func draw_gradient_bg() -> void:
		var start_color = Color(0.6, 0.0, 0.8, 1.0)  # Purple
		var end_color = Color(0.0, 0.0, 0.0, 1.0)    # Black
		
		for y in range(400):
			var progress = float(y) / 400.0
			var color = start_color.lerp(end_color, progress)
			draw_line(Vector2(0, y), Vector2(800, y), color)
	
	func draw_title_text() -> void:
		# Title: "Math Blast" in big white text, centered
		var title_font = ThemeDB.fallback_font
		var title_size = 120
		var title_text = "Math Blast"
		var title_color = Color.WHITE
		
		# Calculate centered position
		var title_width = title_text.length() * title_size * 0.6
		var x = (800 - title_width) / 2.0
		var y = (400 - title_size) / 2.0
		
		draw_string(title_font, Vector2(x, y), title_text, HORIZONTAL_ALIGNMENT_CENTER, -1, title_size, title_color)
	
	func draw_subtext() -> void:
		# Subtext: "No crashes. Pure combos." in yellow
		var sub_font = ThemeDB.fallback_font
		var sub_size = 40
		var sub_text = "No crashes. Pure combos."
		var sub_color = Color.YELLOW
		
		var sub_width = sub_text.length() * sub_size * 0.4
		var x = (800 - sub_width) / 2.0
		var y = 300
		
		draw_string(sub_font, Vector2(x, y), sub_text, HORIZONTAL_ALIGNMENT_CENTER, -1, sub_size, sub_color)
