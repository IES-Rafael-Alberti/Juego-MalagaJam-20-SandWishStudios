extends Control
@onready var notes: Control = $"."

# Texturas
@onready var estado_1: TextureRect = $Estado1
@onready var estado_2: TextureRect = $Estado2
@onready var estado_3: TextureRect = $Estado3
@onready var estado_4: TextureRect = $Estado4

# Labels
@onready var estado_1_lb: Label = $Estado1/Estado1Lb
@onready var estado_2_lb: Label = $Estado2/Estado2Lb
@onready var estado_3_lb: Label = $Estado3/Estado3Lb
@onready var estado_4_lb: Label = $Estado4/Estado4Lb

func _ready() -> void:
	pass 

func actualizar_estado(tipo_actual: String) -> void:
	# Primero ponemos todos en rojo
	var rojo = Color(1, 0, 0)
	var verde = Color(0, 1, 0)

	estado_1.modulate = rojo
	estado_2.modulate = rojo
	estado_3.modulate = rojo
	estado_4.modulate = rojo

	estado_1_lb.modulate = rojo
	estado_2_lb.modulate = rojo
	estado_3_lb.modulate = rojo
	estado_4_lb.modulate = rojo

	# Ahora activamos el correcto en verde
	match tipo_actual:
		"tiki":
			estado_1.modulate = verde
			estado_1_lb.modulate = verde
		"japon":
			estado_2.modulate = verde
			estado_2_lb.modulate = verde
		"carnaval":
			estado_3.modulate = verde
			estado_3_lb.modulate = verde
		"mexicanas":
			estado_4.modulate = verde
			estado_4_lb.modulate = verde
