extends Control

signal se_ha_ido

@onready var cliente: TextureRect = $Cliente
var puede_interactuar: bool = false

func _ready() -> void:
	var centro_x = get_viewport_rect().size.x / 2
	
	cliente.global_position.x = -cliente.size.x 
	
	var tween_entrada = create_tween()
	var destino_final = centro_x - (cliente.size.x / 2)
	
	tween_entrada.tween_property(cliente, "global_position:x", destino_final, 0.8)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	tween_entrada.tween_callback(func(): puede_interactuar = true)

func _on_boton_si_pressed() -> void:
	if not puede_interactuar: return
	puede_interactuar = false
	
	var tween = create_tween()
	tween.tween_property(cliente, "global_position:x", get_viewport_rect().size.x + 100, 0.5)
	tween.tween_callback(func(): 
		se_ha_ido.emit()
		queue_free()
	)

func _on_boton_no_pressed() -> void:
	if not puede_interactuar: return
	puede_interactuar = false
	
	var tween = create_tween()
	tween.tween_property(cliente, "global_position:x", -cliente.size.x - 100, 0.5)
	tween.tween_callback(func(): 
		se_ha_ido.emit()
		queue_free()
	)
