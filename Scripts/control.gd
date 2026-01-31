extends Control

signal se_ha_ido

@onready var cliente: TextureRect = $Cliente
@onready var nodo_mascara_visual: TextureRect = $Cliente/Mascaras 

var puede_interactuar: bool = false
var mascarasDict: Dictionary = {}
var categoria_actual: String = ""
var mascara_categoria: String = ""
var esvip: bool

# Variables para la cola
var en_cola: bool = false
var color_original: Color = Color.WHITE

# Variables para recordar la posición Y original
var orig_y_cliente: float
var orig_y_mascaras: float

var tiempo_maximo: float = 5.0 
# --- NUEVA VARIABLE DE VELOCIDAD ---
var duracion_anim: float = 0.5
# -----------------------------------

@export var mascaras_mexicanas : Array[MascaraData]
@export var mascaras_tiki : Array[MascaraData]
@export var mascaras_carnaval : Array[MascaraData]
@export var mascaras_japon : Array[MascaraData]
@export var aumento: int = 100
@export var reduccion: int = -50
@export var ausencia: int = -25
@export var prob_vip: float = 1
@export var inc_vip: float = 0.2
@onready var tiempo_limite: Timer = $TiempoLimite

func _ready() -> void:
	tiempo_limite.wait_time = tiempo_maximo
	
	var random_idx = randi_range(1, 5)
	var textura_pj = load("res://Assets/pj/pj%d.png" % random_idx)
	if textura_pj:
		cliente.texture = textura_pj
	
	esvip = randf() <= prob_vip
	if esvip:
		color_original = Color.GOLD
	else:
		color_original = Color.WHITE
	
	cliente.modulate = color_original
		
	mascarasDict = {
		"mexicanas": mascaras_mexicanas,
		"tiki": mascaras_tiki,
		"carnaval": mascaras_carnaval,
		"japon": mascaras_japon
	}
	
	orig_y_cliente = cliente.global_position.y
	orig_y_mascaras = nodo_mascara_visual.global_position.y
	
	var centro_x = get_viewport_rect().size.x / 2
	
	cliente.global_position.x = -cliente.size.x
	nodo_mascara_visual.global_position.x = -nodo_mascara_visual.size.x
	
	var destino_final = centro_x - (cliente.size.x / 2)
	var destino_final_mascaras = centro_x - (nodo_mascara_visual.size.x / 2)
	
	if en_cola:
		var offset_cola = 250
		var offset_altura = 60 
		
		var destino_cola = destino_final - offset_cola
		var destino_cola_mascaras = destino_final_mascaras - offset_cola
		
		var destino_cola_y = orig_y_cliente + offset_altura
		var destino_cola_masc_y = orig_y_mascaras + offset_altura
		
		var tween = create_tween().set_parallel(true)
		
		# Usamos duracion_anim ajustada para la cola (un poco más lento que el centro)
		var tiempo_cola = duracion_anim * 1.6
		
		tween.tween_property(cliente, "global_position:x", destino_cola, tiempo_cola)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(nodo_mascara_visual, "global_position:x", destino_cola_mascaras, tiempo_cola)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
		tween.tween_property(cliente, "global_position:y", destino_cola_y, tiempo_cola)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(nodo_mascara_visual, "global_position:y", destino_cola_masc_y, tiempo_cola)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		tween.tween_property(cliente, "scale", Vector2(0.8, 0.8), tiempo_cola)
		tween.tween_property(cliente, "modulate", Color(0.5, 0.5, 0.5, 1), tiempo_cola)
		
	else:
		_animar_entrada_al_centro(destino_final, destino_final_mascaras)

func avanzar_al_centro() -> void:
	en_cola = false
	var centro_x = get_viewport_rect().size.x / 2
	var destino_final = centro_x - (cliente.size.x / 2)
	var destino_final_mascaras = centro_x - (nodo_mascara_visual.size.x / 2)
	
	tiempo_limite.wait_time = tiempo_maximo
	_animar_entrada_al_centro(destino_final, destino_final_mascaras)

func _animar_entrada_al_centro(dest_x, dest_masc_x) -> void:
	var tween = create_tween().set_parallel(true)
	
	# Usamos la variable duracion_anim
	tween.tween_property(cliente, "global_position:x", dest_x, duracion_anim)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(nodo_mascara_visual, "global_position:x", dest_masc_x, duracion_anim)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
	tween.tween_property(cliente, "global_position:y", orig_y_cliente, duracion_anim)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(nodo_mascara_visual, "global_position:y", orig_y_mascaras, duracion_anim)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(cliente, "scale", Vector2(1, 1), duracion_anim)
	tween.tween_property(cliente, "modulate", color_original, duracion_anim)
	
	tween.set_parallel(false)
	tween.tween_callback(func(): puede_interactuar = true)
	tiempo_limite.start()

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

	if randf() <= 0.5:
		mascara_categoria = categoria_actual
	else:
		var opciones_incorrectas = mascarasDict.keys()
		opciones_incorrectas.erase(categoria_actual) 
		mascara_categoria = opciones_incorrectas.pick_random()

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
		aumentar_puntuacion()
		
		if esvip:
			get_parent().multiplicador += inc_vip
	else:
		print(" MAL ")
		reducir_puntuacion(1)
	
	_animar_salida(get_viewport_rect().size.x + 100)

func _on_boton_no_pressed() -> void:
	if not puede_interactuar: return

	if mascara_categoria != categoria_actual:
		print("BIEN ")
		aumentar_puntuacion()
		
	else:
		print("MAL")
		reducir_puntuacion(1)

	_animar_salida(-cliente.size.x - 100)

func _animar_salida(destino_x: float) -> void:
	puede_interactuar = false
	var tween = create_tween().set_parallel(true)
	
	# Usamos la variable duracion_anim
	tween.tween_property(cliente, "global_position:x", destino_x, duracion_anim)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(nodo_mascara_visual, "global_position:x", destino_x, duracion_anim)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	tween.set_parallel(false)
	tween.tween_callback(func(): 
		se_ha_ido.emit()
		queue_free()
	)

func _on_tiempo_limite_timeout() -> void:
	print("Se acabó el tiempo")
	reducir_puntuacion(2)
	_animar_salida(-cliente.size.x - 100) 
	
func aumentar_puntuacion():
	get_parent().puntuacion += aumento
	get_parent().registrar_acierto()
	print(aumento)
	
func reducir_puntuacion(valor: int):
	if valor == 1:
		get_parent().puntuacion += reduccion
	else:
		get_parent().puntuacion += ausencia
	print(reduccion)
