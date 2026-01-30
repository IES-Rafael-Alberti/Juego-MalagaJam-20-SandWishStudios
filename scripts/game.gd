extends Node2D

@onready var invitado_escena = preload("res://scenes/invitado.tscn")
var instancia_actual = null
@onready var timer_cambio: Timer = $TimerCambio
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	progress_bar.max_value = timer_cambio.wait_time
	progress_bar.value = timer_cambio.wait_time
	
	generarInvitado()
	timer_cambio.start() 

func _process(delta: float) -> void:
	actTimerCambio()

func actTimerCambio() -> void:
	progress_bar.value = timer_cambio.time_left


func generarInvitado():
	instancia_actual = invitado_escena.instantiate()
	add_child(instancia_actual)
	
	instancia_actual.se_ha_ido.connect(generarInvitado)
	instancia_actual._generar_mascara()

func dejarPasar():
	if is_instance_valid(instancia_actual):
		instancia_actual._on_boton_si_pressed()

func dejarSalir():
	if is_instance_valid(instancia_actual):
		instancia_actual._on_boton_no_pressed()
		
func cambioFiesta():
	if is_instance_valid(instancia_actual):
		instancia_actual._cambioMascaras()
