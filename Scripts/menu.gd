extends Control

const ventanaSettings := preload("res://Scenes/settings.tscn")
@onready var label_play: Label = $LabelPlay
@onready var label_settings: Label = $LabelSettings
@onready var bgm: AudioStreamPlayer = $BGM

var audio_manager : Audio

var blanco := Color(18.892, 18.892, 18.892, 1.0)
var negro := Color(0.0, 0.0, 0.0, 1.0)
var font_size = 64

func _ready() -> void:
	audio_manager = Audio.new()
	audio_manager.set_player(bgm)
	audio_manager.playMenu()

func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_boton_settings_pressed() -> void:
	var popup := ventanaSettings.instantiate()
	get_tree().root.add_child(popup)


func _on_boton_play_mouse_entered() -> void:
	label_play.label_settings = LabelSettings.new()
	label_play.label_settings.font_color = blanco
	label_play.label_settings.font_size = font_size


func _on_boton_play_mouse_exited() -> void:
	label_play.label_settings = LabelSettings.new()
	label_play.label_settings.font_color = negro
	label_play.label_settings.font_size = font_size


func _on_boton_settings_mouse_entered() -> void:
	label_settings.label_settings = LabelSettings.new()
	label_settings.label_settings.font_color = blanco
	label_settings.label_settings.font_size = font_size 


func _on_boton_settings_mouse_exited() -> void:
	label_settings.label_settings = LabelSettings.new()
	label_settings.label_settings.font_color = negro
	label_settings.label_settings.font_size = font_size
