extends Node2D

@onready var invitado_escena = preload("res://Scenes/invitado.tscn")
@onready var notes = $notes
@onready var multiplicadorLabel: Label = $multiplicador
@onready var puntuacionLabel: Label = $puntuacion
@onready var timer_cambio: Timer = $TimerCambio
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var tiempo_limite: Timer = $TiempoLimite
@onready var tiempo_actualizado: Timer = $TiempoActualizado

var instancia_actual = null
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
var tiempo_ha_cambiado : bool = false

func _ready() -> void:
	randomize()
	timer_cambio.timeout.connect(cambioFiesta)
	progress_bar.max_value = timer_cambio.wait_time
	progress_bar.value = timer_cambio.wait_time
	_actualizar_ui()
	generarInvitado()
	timer_cambio.start()

func _process(_delta: float) -> void:
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
	add_child(instancia_actual)

	if categoria_global != "":
		instancia_actual.categoria_actual = categoria_global

	instancia_actual.se_ha_ido.connect(generarInvitado)
	instancia_actual._generar_mascara()

	if categoria_global == "":
		categoria_global = instancia_actual.categoria_actual
		notes.actualizar_estado(categoria_global)

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

func calcular_tiempo_limite() -> float:
	if tiempo_ha_cambiado:
		tiempo_limite.wait_time = tiempo_actualizado.wait_time
		tiempo_ha_cambiado = false
	return tiempo_limite.wait_time