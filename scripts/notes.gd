extends Control

@onready var notes: Control = $"."

@onready var estado_1: TextureRect = $Estado1
@onready var estado_2: TextureRect = $Estado2
@onready var estado_3: TextureRect = $Estado3
@onready var estado_4: TextureRect = $Estado4

@onready var estado_1_lb: Label = $Estado1/Estado1Lb
@onready var estado_2_lb: Label = $Estado2/Estado2Lb
@onready var estado_3_lb: Label = $Estado3/Estado3Lb
@onready var estado_4_lb: Label = $Estado4/Estado4Lb

const TEX_TICO = preload("res://Assets/iconos/Tico.png")
const TEX_X = preload("res://Assets/iconos/X.png")

var tween_alerta: Tween

func _ready() -> void:
	pass 

func actualizar_estado(tipo_actual: String) -> void:
	var rojo = Color(1, 0, 0)
	var verde = Color(0, 1, 0)

	estado_1.modulate = Color.WHITE
	estado_2.modulate = Color.WHITE
	estado_3.modulate = Color.WHITE
	estado_4.modulate = Color.WHITE

	estado_1.texture = TEX_X
	estado_2.texture = TEX_X
	estado_3.texture = TEX_X
	estado_4.texture = TEX_X

	if estado_1_lb: estado_1_lb.modulate = rojo
	if estado_2_lb: estado_2_lb.modulate = rojo
	if estado_3_lb: estado_3_lb.modulate = rojo
	if estado_4_lb: estado_4_lb.modulate = rojo

	match tipo_actual:
		"tiki":
			estado_1.texture = TEX_TICO
			if estado_1_lb: estado_1_lb.modulate = verde
		"japon":
			estado_2.texture = TEX_TICO
			if estado_2_lb: estado_2_lb.modulate = verde
		"carnaval":
			estado_3.texture = TEX_TICO
			if estado_3_lb: estado_3_lb.modulate = verde
		"mexicanas":
			estado_4.texture = TEX_TICO
			if estado_4_lb: estado_4_lb.modulate = verde


func iniciar_parpadeo() -> void:
	if tween_alerta and tween_alerta.is_valid():
		tween_alerta.kill()
	
	tween_alerta = create_tween().set_loops()
	tween_alerta.tween_property(self, "modulate", Color(1, 0.6, 0.6), 0.5) 
	tween_alerta.tween_property(self, "modulate", Color.WHITE, 0.5)

func detener_parpadeo() -> void:
	if tween_alerta and tween_alerta.is_valid():
		tween_alerta.kill()
	self.modulate = Color.WHITE

func notificar_cambio() -> void:
	detener_parpadeo()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
