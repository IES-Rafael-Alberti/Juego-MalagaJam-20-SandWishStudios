extends Control

signal se_ha_ido

@onready var cliente: TextureRect = $Cliente
@onready var nodo_mascara_visual: TextureRect = $Cliente/Mascaras 

var puede_interactuar: bool = false
var mascarasDict: Dictionary = {}
var categoria_actual: String = ""

@export var mascaras_mexicanas : Array[MascaraData]
@export var mascaras_tiki : Array[MascaraData]
@export var mascaras_carnaval : Array[MascaraData]
@export var mascaras_japon : Array[MascaraData]

func _ready() -> void:
	mascarasDict = {
		"mexicanas": mascaras_mexicanas,
		"tiki": mascaras_tiki,
		"carnaval": mascaras_carnaval,
		"japon": mascaras_japon
	}
	
	_cambioMascaras()
	
	var centro_x = get_viewport_rect().size.x / 2
	cliente.global_position.x = -cliente.size.x
	nodo_mascara_visual.global_position.x = -nodo_mascara_visual.size.x
	
	var destino_final = centro_x - (cliente.size.x / 2)
	var destino_final_mascaras = centro_x - (nodo_mascara_visual.size.x / 2)
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(cliente, "global_position:x", destino_final, 0.8)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
	tween.tween_property(nodo_mascara_visual, "global_position:x", destino_final_mascaras, 0.8)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.set_parallel(false)
	tween.tween_callback(func(): puede_interactuar = true)


func _cambioMascaras() -> void:
	var categorias = mascarasDict.keys() 
	var opciones_validas: Array = []
	
	for c in categorias:
		if c != categoria_actual:
			opciones_validas.append(c)
	
	if opciones_validas.size() > 0:
		categoria_actual = opciones_validas.pick_random()
		_generar_mascara()
	else:
		categoria_actual = categorias.pick_random()
		_generar_mascara()

func _generar_mascara() -> void:
	var lista_mascaras: Array[MascaraData] = mascarasDict[categoria_actual]
	
	if lista_mascaras.size() > 0:
		var rng = randi_range(0, lista_mascaras.size() - 1)
		nodo_mascara_visual.texture = lista_mascaras[rng].icon
		print("Categoría seleccionada: ", categoria_actual) # Debug
	else:
		push_warning("La lista de máscaras para " + categoria_actual + " está vacía.")


func _on_boton_si_pressed() -> void:
	if not puede_interactuar: return
	_animar_salida(get_viewport_rect().size.x + 100)

func _on_boton_no_pressed() -> void:
	if not puede_interactuar: return
	_animar_salida(-cliente.size.x - 100)

func _animar_salida(destino_x: float) -> void:
	puede_interactuar = false
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(cliente, "global_position:x", destino_x, 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tween.tween_property(nodo_mascara_visual, "global_position:x", destino_x, 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	tween.set_parallel(false)
	tween.tween_callback(func(): 
		se_ha_ido.emit()
		queue_free()
	)
