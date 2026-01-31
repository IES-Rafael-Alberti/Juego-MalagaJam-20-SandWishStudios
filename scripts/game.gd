extends Node2D

@onready var invitado_escena = preload("res://Scenes/invitado.tscn")
@onready var notes = $notes
@onready var multiplicadorLabel: Label = $multiplicador
@onready var puntuacionLabel: Label = $puntuacion

var instancia_actual = null
@onready var timer_cambio: Timer = $TimerCambio
@onready var progress_bar: ProgressBar = $ProgressBar
@export var limiteDif: int = 10
@export var reduccion_tiempo: float = 0.5 
var aciertos_totales: int = 0
var tiempo_limite_actual: float = 5.0 

var puntuacion: int = 0:
	set(valor):
		puntuacion = valor
		_actualizar_ui()

var multiplicador: float = 1.0:
	set(valor):
		multiplicador = valor
		_actualizar_ui()

var categoria_global: String = ""
var categoria_pendiente: String= ""
var timeout_pausado := false

func _ready() -> void:
	randomize()
	
	timer_cambio.timeout.connect(cambioFiesta)
	
	progress_bar.max_value = timer_cambio.wait_time
	progress_bar.value = timer_cambio.wait_time
	
	_actualizar_ui()
	
	generarInvitado()
	timer_cambio.start()

func _process(delta: float) -> void:
	actTimerCambio()

func actTimerCambio() -> void:
	if timeout_pausado:
		progress_bar.value = 0
	else:
		progress_bar.value = timer_cambio.time_left

func generarInvitado():
	if categoria_pendiente != "":
		categoria_global = categoria_pendiente
		categoria_pendiente = ""
		notes.actualizar_estado(categoria_global)

	instancia_actual = invitado_escena.instantiate()
	
	instancia_actual.tiempo_maximo = tiempo_limite_actual
	
	add_child(instancia_actual)

	if categoria_global != "":
		instancia_actual.categoria_actual = categoria_global

	instancia_actual.se_ha_ido.connect(generarInvitado)
	instancia_actual._generar_mascara()

	if categoria_global == "":
		categoria_global = instancia_actual.categoria_actual
		notes.actualizar_estado(categoria_global)

func registrar_acierto():
	aciertos_totales += 1
	if aciertos_totales > 0 and aciertos_totales % limiteDif == 0:
		tiempo_limite_actual -= reduccion_tiempo
		if tiempo_limite_actual < 1.0:
			tiempo_limite_actual = 1.0
		print("¡Dificultad aumentada! Nuevo tiempo: ", tiempo_limite_actual)
# --------------------------------------------------

func dejarPasar():
	if is_instance_valid(instancia_actual):
		_rearmar_timer_si_timeout()
		instancia_actual._on_boton_si_pressed()

func dejarSalir():
	if is_instance_valid(instancia_actual):
		_rearmar_timer_si_timeout()
		instancia_actual._on_boton_no_pressed()
		
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
	get_tree().change_scene_to_file("res://scenes/fin_juego.tscn")
