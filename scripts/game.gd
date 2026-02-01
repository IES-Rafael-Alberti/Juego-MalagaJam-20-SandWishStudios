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
	else:
		progress_bar.value = timer_cambio.time_left
		
		if timer_cambio.time_left <= tiempo_aviso and not avisando_cambio:
			avisando_cambio = true
			iniciar_parpadeo_cartel()
		elif timer_cambio.time_left > tiempo_aviso and avisando_cambio and categoria_pendiente == "":
			avisando_cambio = false
			detener_parpadeo_cartel()

func iniciar_parpadeo_cartel() -> void:
	if tween_cartel and tween_cartel.is_valid():
		tween_cartel.kill()
	
	tween_cartel = create_tween().set_loops()
	tween_cartel.tween_property(cartel, "modulate", Color(1, 0.6, 0.6), 0.5)
	tween_cartel.tween_property(cartel, "modulate", Color.WHITE, 0.5)

func detener_parpadeo_cartel() -> void:
	if tween_cartel and tween_cartel.is_valid():
		tween_cartel.kill()
	cartel.modulate = Color.WHITE

func actualizar_cartel_textura(categoria: String) -> void:
	match categoria:
		"tiki": cartel.texture = CARTEL_TIKI
		"japon": cartel.texture = CARTEL_JAPON
		"carnaval": cartel.texture = CARTEL_CARNAVAL
		"mexicanas": cartel.texture = CARTEL_MEXICO

func generarInvitado():
	if categoria_pendiente != "":
		categoria_global = categoria_pendiente
		categoria_pendiente = ""
		
		notes.actualizar_estado(categoria_global)
		notes.notificar_cambio()
		
		actualizar_cartel_textura(categoria_global)
		detener_parpadeo_cartel()
		avisando_cambio = false
	
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
		actualizar_cartel_textura(categoria_global)
		
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
	timeout_pausado = true
	timer_cambio.stop()
	progress_bar.value = 0
	
	if is_instance_valid(instancia_actual):
		categoria_pendiente = instancia_actual.obtener_otra_categoria(categoria_global)
		print("¡Cambio de fiesta pendiente! Siguiente invitado será: ", categoria_pendiente)

	timer_cambio.start()

func _rearmar_timer_si_timeout() -> void:
	if timeout_pausado:
		timeout_pausado = false
		progress_bar.value = timer_cambio.wait_time
		timer_cambio.start()

func _actualizar_ui() -> void:
	if puntuacionLabel:
		puntuacionLabel.text = str(puntuacion)
			
	if multiplicadorLabel:
		multiplicadorLabel.text = "x %.1f" % multiplicador

func finJuego():
	timer_cambio.stop()
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
