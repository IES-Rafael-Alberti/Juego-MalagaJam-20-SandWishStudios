extends Node2D

@onready var invitado_escena = preload("res://Scenes/invitado.tscn")

var instancia_actual = null
@onready var timer_cambio: Timer = $TimerCambio
@onready var progress_bar: ProgressBar = $ProgressBar

var categoria_global: String = ""

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
	
	if categoria_global != "":
		instancia_actual.categoria_actual = categoria_global
	
	instancia_actual.se_ha_ido.connect(generarInvitado)
	instancia_actual._generar_mascara()
	
	if categoria_global == "":
		categoria_global = instancia_actual.categoria_actual

func dejarPasar():
	if is_instance_valid(instancia_actual):
		instancia_actual._on_boton_si_pressed()

func dejarSalir():
	if is_instance_valid(instancia_actual):
		instancia_actual._on_boton_no_pressed()
		
func cambioFiesta():
	if is_instance_valid(instancia_actual):
		var nueva_cat = instancia_actual.obtener_otra_categoria(categoria_global)
		categoria_global = nueva_cat
		print("Cambio de fiesta. Siguiente invitado será: ", categoria_global)
		
		timer_cambio.start()
		
func finJuego():
	get_tree().quit()
