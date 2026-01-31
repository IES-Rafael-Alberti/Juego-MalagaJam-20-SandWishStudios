extends Node

func _ready() -> void:
  SilentWolf.configure({
	"api_key": "05OzzGlCis42wTRqZbgVq4vHycVZueFW9sRNvpww",
	"game_id": "maskness",
	"log_level": 1
  })

  SilentWolf.configure_scores({
	"open_scene_on_close": "res://scenes/fin_juego.tscn"
  })
