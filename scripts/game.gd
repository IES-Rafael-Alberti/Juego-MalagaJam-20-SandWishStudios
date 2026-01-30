extends Node2D

@onready var invitado_escena = preload("res://scenes/invitado.tscn")
var instancia_actual = null

func _ready() -> void:
	generarInvitado()

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
