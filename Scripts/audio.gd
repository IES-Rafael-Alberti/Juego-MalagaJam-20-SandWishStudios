class_name Audio
extends  Node

const TRACK_MENU = preload("res://Assets/sounds/MainMenuTheme.wav")
const TRACK_GAMEPLAY = preload("res://Assets/sounds/FondoMusica.wav")

var music_player: AudioStreamPlayer

func set_player(p: AudioStreamPlayer) -> void:
	music_player = p
	
func playGameplay() -> void:
	if music_player:
		#print("Tengo player: ", music_player)
		#print("Antes stream: ", music_player.stream)
		music_player.stream = TRACK_GAMEPLAY
		#print("Después stream: ", music_player.stream)
		music_player.play()
		#print("is_playing: ", music_player.is_playing())
	else:
		print("NO tengo player en el juego")

func playMenu() -> void:
	if music_player:
		#print("Tengo player: ", music_player)
		#print("Antes stream: ", music_player.stream)
		music_player.stream = TRACK_MENU
		#print("Después stream: ", music_player.stream)
		music_player.play()
		#print("is_playing: ", music_player.is_playing())
	else:
		print("NO tengo player en el menú")
