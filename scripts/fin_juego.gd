extends Control

@onready var reiniciar: TextureButton = $TextureRect/Reiniciar
@onready var salir: TextureButton = $TextureRect/Salir
@onready var puntuacionLb: Label = $TextureRect/puntuacionLb

@onready var bgm: AudioStreamPlayer = $BGM

var audio_manager : Audio

var puntosBase: int = 0
var multiplicador: float = 1.0
var total_final: int = 0

func _ready() -> void:
	puntuacionLb.text = "Puntos: %d  x%.1f\nTotal: %d" % [puntosBase, multiplicador, puntosBase]

	await get_tree().create_timer(1.0).timeout

	total_final = int(round(puntosBase * multiplicador))
	await animacion_puntuacion(puntosBase, total_final, 1.0)
	
	audio_manager = Audio.new()
	audio_manager.set_player(bgm)
	audio_manager.playMenu()

func _on_reiniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_salir_pressed() -> void:
	get_tree().quit()

func animacion_puntuacion(desde: int, hasta: int, duracion: float) -> void:
	if duracion <= 0.0 or desde == hasta:
		puntuacionLb.add_theme_font_size_override("font_size", 90)
		puntuacionLb.text = "Puntos: %d  x%.1f\nTotal: %d" % [puntosBase, multiplicador, hasta]
		return

	var t := 0.0
	while t < duracion:
		t += get_process_delta_time()
		var alpha: float = clampf(t / duracion, 0.0, 1.0)

		var valor := int(lerp(float(desde), float(hasta), alpha))

		var size := 90 + (2 if (valor % 3 == 0) else 0)
		puntuacionLb.add_theme_font_size_override("font_size", size)

		puntuacionLb.text = "Puntos: %d  x%.1f\nTotal: %d" % [puntosBase, multiplicador, valor]
		await get_tree().process_frame

	puntuacionLb.add_theme_font_size_override("font_size", 90)
	puntuacionLb.text = "Puntos: %d  x%.1f\nTotal: %d" % [puntosBase, multiplicador, hasta]

func _on_texture_button_pressed() -> void:
	var total := int(round(puntosBase * multiplicador))
	Global.last_score = total
	get_tree().change_scene_to_file("res://addons/talo/samples/leaderboards/leaderboard.tscn")
