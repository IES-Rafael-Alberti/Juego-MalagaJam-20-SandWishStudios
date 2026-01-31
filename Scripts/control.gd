extends Control

signal se_ha_ido

@onready var cliente: TextureRect = $Cliente
@onready var nodo_mascara_visual: TextureRect = $Cliente/Mascaras 
@onready var progress_bar_radial: TextureProgressBar = $TextureProgressBar

var puede_interactuar: bool = false
var mascarasDict: Dictionary = {}
var categoria_actual: String = ""
var mascara_categoria: String = ""
var esvip: bool

var en_cola: bool = false
var color_original: Color = Color.WHITE

var orig_y_cliente: float
var orig_y_mascaras: float

var tiempo_maximo: float = 5.0 
var duracion_anim: float = 0.5

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
	progress_bar_radial.visible = false
	tiempo_limite.wait_time = tiempo_maximo
	
	_configurar_barra_radial()
	
	var random_idx = randi_range(1, 5)
	var textura_pj = load("res://Assets/pj/pj%d.png" % random_idx)
	if textura_pj:
		cliente.texture = textura_pj
	
	esvip = randf() <= prob_vip
	if esvip:
		color_original = Color.WHITE
		
		var outline_shader = load("res://sharders/2doutline.gdshader")
		
		var vip_mat = ShaderMaterial.new()
		vip_mat.shader = outline_shader
		vip_mat.set_shader_parameter("color", Color(1, 0.84, 0, 1))
		vip_mat.set_shader_parameter("width", 6.0)
		vip_mat.set_shader_parameter("inside", true)
		cliente.material = vip_mat

		var mask_mat = ShaderMaterial.new()
		mask_mat.shader = outline_shader
		mask_mat.set_shader_parameter("color", Color(1, 0.84, 0, 1))
		mask_mat.set_shader_parameter("width", 6.0)
		mask_mat.set_shader_parameter("inside", true)
		nodo_mascara_visual.material = mask_mat
		
		nodo_mascara_visual.modulate = Color(1, 0.84, 0)
		
	else:
		color_original = Color.WHITE
		cliente.material = null
		nodo_mascara_visual.material = null
		nodo_mascara_visual.modulate = Color.WHITE
	
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

func _process(_delta: float) -> void:
	if puede_interactuar and not en_cola and is_instance_valid(tiempo_limite):
		var tiempo_restante = tiempo_limite.time_left
		var porcentaje = (tiempo_restante / tiempo_limite.wait_time) * 100
		
		progress_bar_radial.value = porcentaje
		progress_bar_radial.visible = true
		
		progress_bar_radial.global_position = cliente.global_position + Vector2(cliente.size.x - 20, -10)
		
		if porcentaje > 50:
			progress_bar_radial.tint_progress = Color.SPRING_GREEN
		elif porcentaje > 25:
			progress_bar_radial.tint_progress = Color.GOLD
		else:
			progress_bar_radial.tint_progress = Color.TOMATO
	else:
		progress_bar_radial.visible = false

func _configurar_barra_radial() -> void:
	var gradiente = Gradient.new()
	gradiente.offsets = [0.0, 0.95, 1.0]
	gradiente.colors = [Color.WHITE, Color.WHITE, Color.TRANSPARENT]
	
	var tex = GradientTexture2D.new()
	tex.gradient = gradiente
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	
	tex.fill_to = Vector2(0.5, 0.0) 
	
	tex.width = 48
	tex.height = 48
	
	progress_bar_radial.texture_under = tex
	progress_bar_radial.texture_progress = tex
	
	progress_bar_radial.tint_under = Color(0, 0, 0, 0.4) 
	progress_bar_radial.fill_mode = TextureProgressBar.FILL_CLOCKWISE
	progress_bar_radial.min_value = 0
	progress_bar_radial.max_value = 100
	
	progress_bar_radial.custom_minimum_size = Vector2(38, 38)

func avanzar_al_centro() -> void:
	en_cola = false
	var centro_x = get_viewport_rect().size.x / 2
	var destino_final = centro_x - (cliente.size.x / 2)
	var destino_final_mascaras = centro_x - (nodo_mascara_visual.size.x / 2)
	
	tiempo_limite.wait_time = tiempo_maximo
	_animar_entrada_al_centro(destino_final, destino_final_mascaras)

func _animar_entrada_al_centro(dest_x, dest_masc_x) -> void:
	var tween = create_tween().set_parallel(true)
	
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
		aumentar_puntuacion()
		if esvip:
			get_parent().multiplicador += inc_vip
	else:
		reducir_puntuacion(1)
	
	_animar_salida(get_viewport_rect().size.x + 100)

func _on_boton_no_pressed() -> void:
	if not puede_interactuar: return

	if mascara_categoria != categoria_actual:
		aumentar_puntuacion()
	else:
		reducir_puntuacion(1)

	_animar_salida(-cliente.size.x - 100)

func _animar_salida(destino_x: float) -> void:
	puede_interactuar = false
	var tween = create_tween().set_parallel(true)
	
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
	reducir_puntuacion(2)
	_animar_salida(-cliente.size.x - 100) 
	
func aumentar_puntuacion():
	get_parent().puntuacion += aumento
	get_parent().registrar_acierto()
	
func reducir_puntuacion(valor: int):
	if valor == 1:
		get_parent().puntuacion += reduccion
	else:
		get_parent().puntuacion += ausencia
