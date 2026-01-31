extends Control

@onready var reiniciar: TextureButton = $TextureRect/Reiniciar
@onready var salir: TextureButton = $TextureRect/Salir

func _ready() -> void:
	pass

func _on_reiniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	

func _on_salir_pressed() -> void:
	get_tree().quit()
