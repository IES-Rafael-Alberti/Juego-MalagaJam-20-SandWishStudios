extends Node2D

@onready var invitado_escena = preload("res://Scenes/invitado.tscn")
@onready var fin_juego_scene: PackedScene = preload("res://Scenes/fin_juego.tscn")
@onready var notes = $notes
@onready var multiplicadorLabel: Label = $multiplicador
@onready var puntuacionLabel: Label = $puntuacion
@onready var cartel: TextureRect = $cartel

@onready var timer_juego: Timer = $TimerJuego
@onready var label_reloj: Label = $reloj/tiempoRes

@onready var btn_entra: TextureButton = $PanelInf/Entra
@onready var btn_fuera: TextureButton = $PanelInf/Fuera

# Constantes de texturas para el cartel
const CARTEL_TIKI = preload("res://Assets/carteles/Tiki.png")
const CARTEL_JAPON = preload("res://Assets/carteles/Nipón.png")
const CARTEL_CARNAVAL = preload("res://Assets/carteles/Carnaval.png")
const CARTEL_MEXICO = preload("res://Assets/carteles/Mexican.png")

var instancia_actual = null
var instancia_siguiente = null 

@onready var timer_cambio: Timer = $TimerCambio
@onready var progress_bar: ProgressBar = $ProgressBar
@export var limiteDif: int = 10
@export var reduccion_tiempo: float = 0.5 
var aciertos_totales: int = 0
var tiempo_limite_actual: float = 5.0

var _puntuacion: int = 0
var puntuacion: int:
	get: return _puntuacion
	set(valor):
		_puntuacion = valor
		_actualizar_ui()

var _multiplicador: float = 1.0
var multiplicador: float:
	get: return _multiplicador
	set(valor):
		_multiplicador = valor
		_actualizar_ui()

var categoria_global: String = ""
var categoria_pendiente: String= ""
var timeout_pausado := false

var avisando_cambio: bool = false
var tiempo_aviso: float = 3.0

var tex_entra_normal: Texture2D
var tex_fuera_normal: Texture2D

@onready var bgm: AudioStreamPlayer = $BGM
@onready var audio_fuera: AudioStreamPlayer = $PanelInf/Fuera/AudioFuera
@onready var audio_entra: AudioStreamPlayer = $PanelInf/Entra/AudioEntra

var audio_manager : Audio
var tween_cartel: Tween

func _ready() -> void:
	randomize()
	
	tex_entra_normal = btn_entra.texture_normal
	tex_fuera_normal = btn_fuera.texture_normal
	
	btn_entra.mouse_entered.connect(func(): btn_entra.modulate = Color(0.8, 0.8, 0.8))
	btn_entra.mouse_exited.connect(func(): btn_entra.modulate = Color.WHITE)
	
	btn_fuera.mouse_entered.connect(func(): btn_fuera.modulate = Color(0.8, 0.8, 0.8))
	btn_fuera.mouse_exited.connect(func(): btn_fuera.modulate = Color.WHITE)
	
	timer_cambio.timeout.connect(cambioFiesta)
	
	progress_bar.max_value = timer_cambio.wait_time
	progress_bar.value = timer_cambio.wait_time
	
	_actualizar_ui()
	
	generarInvitado()
	timer_cambio.start()
	
	_actualizar_reloj()
	
	audio_manager = Audio.new()
	audio_manager.set_player(bgm)
	audio_manager.playGameplay()
	
	# Configuración inicial del cartel
	_actualizar_pivot_cartel()

func _process(delta: float) -> void:
	actTimerCambio()
	_actualizar_reloj()
	
	if Input.is_action_pressed("aceptar"):
		btn_entra.texture_normal = btn_entra.texture_pressed
	else:
		btn_entra.texture_normal = tex_entra_normal
		
	if Input.is_action_just_pressed("aceptar"):
		dejarPasar()

	if Input.is_action_pressed("expulsar"):
		btn_fuera.texture_normal = btn_fuera.texture_pressed
	else:
		btn_fuera.texture_normal = tex_fuera_normal
		
	if Input.is_action_just_pressed("expulsar"):
		dejarSalir()

func _actualizar_reloj() -> void:
	if is_instance_valid(timer_juego) and is_instance_valid(label_reloj):
		var tiempo_restante = timer_juego.time_left
		var minutos = floor(tiempo_restante / 60)
		var segundos = int(tiempo_restante) % 60
		label_reloj.text = "%d:%02d" % [minutos, segundos]

func actTimerCambio() -> void:
	if timeout_pausado:
		progress_bar.value = 0
		# Si está pausado (esperando al jugador), el parpadeo continúa.
	else:
		progress_bar.value = timer_cambio.time_left
		
		# Iniciar aviso si queda poco tiempo y NO estamos avisando ya
		if timer_cambio.time_left <= tiempo_aviso and not avisando_cambio:
			iniciar_parpadeo_cartel()
		
		# Caso de seguridad: Si por alguna razón (bonus, etc) el tiempo sube, cancelamos aviso
		elif timer_cambio.time_left > tiempo_aviso and avisando_cambio and categoria_pendiente == "":
			detener_parpadeo_cartel()

# --- Lógica Visual del Cartel ---

func _actualizar_pivot_cartel() -> void:
	# Importante: Pone el pivote en el centro para que escale bonito
	cartel.pivot_offset = cartel.size / 2
	cartel.scale = Vector2.ONE

func iniciar_parpadeo_cartel() -> void:
	avisando_cambio = true
	if tween_cartel and tween_cartel.is_valid():
		tween_cartel.kill()
	
	tween_cartel = create_tween().set_loops()
	# Parpadeo translúcido: Alpha 0.4 <-> 1.0
	tween_cartel.tween_property(cartel, "modulate", Color(1, 1, 1, 0.4), 0.5).set_ease(Tween.EASE_IN_OUT)
	tween_cartel.tween_property(cartel, "modulate", Color.WHITE, 0.5).set_ease(Tween.EASE_IN_OUT)

func detener_parpadeo_cartel() -> void:
	avisando_cambio = false
	if tween_cartel and tween_cartel.is_valid():
		tween_cartel.kill()
	cartel.modulate = Color.WHITE

func animar_cambio_cartel(nueva_categoria: String) -> void:
	# 1. Detenemos cualquier parpadeo previo y reseteamos el estado
	detener_parpadeo_cartel()
	
	var nueva_textura = null
	match nueva_categoria:
		"tiki": nueva_textura = CARTEL_TIKI
		"japon": nueva_textura = CARTEL_JAPON
		"carnaval": nueva_textura = CARTEL_CARNAVAL
		"mexicanas": nueva_textura = CARTEL_MEXICO
	
	if nueva_textura:
		var tween = create_tween()
		
		# Animación de salida (desaparecer)
		tween.tween_property(cartel, "scale", Vector2.ZERO, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
		
		# Callback para cambiar la textura y recalcular el pivote justo cuando es invisible
		tween.tween_callback(func(): 
			cartel.texture = nueva_textura
			# Forzamos actualización de tamaño si es necesario y pivote
			cartel.reset_size() 
			cartel.pivot_offset = cartel.size / 2 
		)
		
		# Animación de entrada (aparecer con rebote)
		tween.tween_property(cartel, "scale", Vector2.ONE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

# --------------------------------

func generarInvitado():
	if categoria_pendiente != "":
		categoria_global = categoria_pendiente
		categoria_pendiente = ""
		
		notes.actualizar_estado(categoria_global)
		notes.notificar_cambio()
		
		# Cambio visual del cartel
		animar_cambio_cartel(categoria_global)
	
	var vel_anim = clamp(tiempo_limite_actual * 0.1, 0.1, 0.5)

	if instancia_siguiente != null:
		instancia_actual = instancia_siguiente
		instancia_siguiente = null
		
		instancia_actual.tiempo_maximo = tiempo_limite_actual
		instancia_actual.duracion_anim = vel_anim
		
		instancia_actual.avanzar_al_centro()
		
	else:
		instancia_actual = invitado_escena.instantiate()
		instancia_actual.tiempo_maximo = tiempo_limite_actual
		instancia_actual.en_cola = false 
		instancia_actual.duracion_anim = vel_anim
		add_child(instancia_actual)

		if categoria_global != "":
			instancia_actual.categoria_actual = categoria_global
		
		instancia_actual._generar_mascara()

	if categoria_global != "":
		instancia_actual.categoria_actual = categoria_global

	instancia_actual.se_ha_ido.connect(generarInvitado)

	if categoria_global == "":
		categoria_global = instancia_actual.categoria_actual
		notes.actualizar_estado(categoria_global)
		
		# Asignación inicial de textura sin animación
		match categoria_global:
			"tiki": cartel.texture = CARTEL_TIKI
			"japon": cartel.texture = CARTEL_JAPON
			"carnaval": cartel.texture = CARTEL_CARNAVAL
			"mexicanas": cartel.texture = CARTEL_MEXICO
		_actualizar_pivot_cartel()
		
	_crear_invitado_en_cola()

func _crear_invitado_en_cola():
	instancia_siguiente = invitado_escena.instantiate()
	instancia_siguiente.tiempo_maximo = tiempo_limite_actual
	instancia_siguiente.en_cola = true
	
	var vel_anim = clamp(tiempo_limite_actual * 0.1, 0.1, 0.5)
	instancia_siguiente.duracion_anim = vel_anim
	
	add_child(instancia_siguiente)

	if categoria_global != "":
		instancia_siguiente.categoria_actual = categoria_global

	instancia_siguiente._generar_mascara()

func registrar_acierto():
	aciertos_totales += 1
	if aciertos_totales > 0 and aciertos_totales % limiteDif == 0:
		tiempo_limite_actual -= reduccion_tiempo
		if tiempo_limite_actual < 1.0:
			tiempo_limite_actual = 1.0
		print("¡Dificultad aumentada! Nuevo tiempo: ", tiempo_limite_actual)

func dejarPasar():
	if is_instance_valid(instancia_actual):
		_rearmar_timer_si_timeout()
		instancia_actual._on_boton_si_pressed()
		
		audio_manager.set_player(audio_entra)
		audio_manager.playYes()

func dejarSalir():
	if is_instance_valid(instancia_actual):
		_rearmar_timer_si_timeout()
		instancia_actual._on_boton_no_pressed()
		
		audio_manager.set_player(audio_fuera)
		audio_manager.playNo()
		
func cambioFiesta():
	# El tiempo se ha agotado. Pausamos la lógica del timer visual.
	timeout_pausado = true
	timer_cambio.stop()
	progress_bar.value = 0
	
	# El parpadeo CONTINÚA aquí (porque avisando_cambio sigue true y timeout_pausado es true)
	
	if is_instance_valid(instancia_actual):
		categoria_pendiente = instancia_actual.obtener_otra_categoria(categoria_global)
		print("¡Cambio de fiesta pendiente! Siguiente invitado será: ", categoria_pendiente)

	timer_cambio.start()

func _rearmar_timer_si_timeout() -> void:
	# Esta función se llama cuando el jugador ACTÚA (dejar pasar/salir).
	# Si estábamos en "timeout_pausado" (esperando el cambio), reseteamos todo.
	if timeout_pausado:
		timeout_pausado = false
		progress_bar.value = timer_cambio.wait_time
		timer_cambio.start()
		
		# CRÍTICO: Aquí es donde paramos el aviso, porque ya hemos atendido el cambio.
		detener_parpadeo_cartel()

func _actualizar_ui() -> void:
	if puntuacionLabel:
		puntuacionLabel.text = str(puntuacion)
			
	if multiplicadorLabel:
		multiplicadorLabel.text = "x %.1f" % multiplicador

func finJuego():
	timer_cambio.stop()
	detener_parpadeo_cartel()
	set_process(false)

	call_deferred("_cambiar_a_fin_juego")

func _cambiar_a_fin_juego():
	var fin_scene := fin_juego_scene.instantiate() as Control

	fin_scene.puntosBase = puntuacion
	fin_scene.multiplicador = multiplicador

	if get_tree().current_scene:
		get_tree().current_scene.queue_free()

	get_tree().root.add_child(fin_scene)
	get_tree().current_scene = fin_scene
