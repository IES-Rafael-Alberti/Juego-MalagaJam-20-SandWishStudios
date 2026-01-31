extends CanvasLayer

@onready var label_salir: Label = $LabelSalir

var blanco := Color(18.892, 18.892, 18.892, 1.0)
var negro := Color(0.0, 0.0, 0.0, 1.0)
var font_size = 48
var bus_index = AudioServer.get_bus_index("Master")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_boton_salir_pressed() -> void:
	queue_free() # Replace with function body.


func _on_slider_volumen_value_changed(value: float) -> void:
	
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

	if value == 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)


func _on_boton_salir_mouse_entered() -> void:
	label_salir.label_settings = LabelSettings.new()
	label_salir.label_settings.font_color = blanco
	label_salir.label_settings.font_size = font_size


func _on_boton_salir_mouse_exited() -> void:
	label_salir.label_settings = LabelSettings.new()
	label_salir.label_settings.font_color = negro
	label_salir.label_settings.font_size = font_size
