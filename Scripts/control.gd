extends Control

@onready var cliente: TextureRect = $Cliente
@onready var boton_si: Button = $BotonSi
@onready var boton_no: Button = $BotonNo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_boton_si_pressed() -> void:
	
	#print("Pa entro")
	
	var tween = create_tween()
	
	tween.tween_property($Cliente, "position", $Cliente.position + Vector2(350, 0), 0.5)
	
	tween.tween_callback($Cliente.queue_free)
	
func _on_boton_no_pressed() -> void:
	
	#print("Denegado")
	
	var tween = create_tween()
	
	tween.tween_property($Cliente, "position", $Cliente.position + Vector2(-350, 0), 0.5)
	
	tween.tween_callback($Cliente.queue_free)
