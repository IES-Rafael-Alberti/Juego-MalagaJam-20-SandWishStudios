extends Control

signal se_ha_ido

@onready var cliente: TextureRect = $Cliente
@onready var nodo_mascara_visual: TextureRect = $Cliente/Mascaras 

var puede_interactuar: bool = false
var mascarasDict: Dictionary = {}
var categoria_actual: String = ""
var mascara_categoria: String = ""

@export var mascaras_mexicanas : Array[MascaraData]
@export var mascaras_tiki : Array[MascaraData]
@export var mascaras_carnaval : Array[MascaraData]
@export var mascaras_japon : Array[MascaraData]

var num_aciertos = 0

func _ready() -> void:
	mascarasDict = {
		"mexicanas": mascaras_mexicanas,
		"tiki": mascaras_tiki,
		"carnaval": mascaras_carnaval,
		"japon": mascaras_japon
	}
	
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
	
	get_parent().tiempo_limite.wait_time = get_parent().calcular_tiempo_limite()
	
	print("Tiempo ready:", get_parent().tiempo_limite.wait_time)

func obtener_otra_categoria(actual: String) -> String:
	var categorias = mascarasDict.keys()
	var opciones = []
	for c in categorias:
		if c != actual:
			opciones.append(c)
	
	if opciones.size() > 0:
		return opciones.pick_random()
	return categorias.pick_random()

func _generar_mascara() -> void:
	if categoria_actual == "":
		categoria_actual = mascarasDict.keys().pick_random()

	mascara_categoria = mascarasDict.keys().pick_random()

	var lista_mascaras: Array[MascaraData] = mascarasDict[mascara_categoria]
	
	if lista_mascaras.size() > 0:
		var rng = randi_range(0, lista_mascaras.size() - 1)
		nodo_mascara_visual.texture = lista_mascaras[rng].icon
	else:
		push_warning("Lista vacía para: " + mascara_categoria)

func _on_boton_si_pressed() -> void:
	if not puede_interactuar: return
	
	if mascara_categoria == categoria_actual:
		print("BIEN ")
		#num_aciertos = 10
		num_aciertos += 0
		if num_aciertos >= 10:
			reducir_tiempo()
	else:
		print(" MAL ")
	
	animar_salida(get_viewport_rect().size.x + 100)

func _on_boton_no_pressed() -> void:
	if not puede_interactuar: return

	if mascara_categoria != categoria_actual:
		print("BIEN ")
		#num_aciertos = 10
		num_aciertos += 0
		if num_aciertos >= 10:
			reducir_tiempo()
	else:
		print("MAL")

	animar_salida(-cliente.size.x - 100)

func animar_salida(destino_x: float) -> void:
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
	
func reducir_tiempo():
	get_parent().tiempo_actualizado.wait_time = get_parent().tiempo_limite.wait_time * 0.5
	print("Reducido tiempo:", get_parent().tiempo_actualizado.wait_time)
	get_parent().tiempo_ha_cambiado = true
