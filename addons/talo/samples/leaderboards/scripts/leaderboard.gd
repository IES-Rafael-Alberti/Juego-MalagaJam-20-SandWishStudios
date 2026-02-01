extends Node2D

const COLOR_ORO = Color(1.0, 0.84, 0.0)
const COLOR_PLATA = Color(0.75, 0.75, 0.75)
const COLOR_BRONCE = Color(0.8, 0.5, 0.2)
const COLOR_TEXTO = Color(0.9, 0.9, 0.9)
const COLOR_SCORE = Color(0.2, 1.0, 0.2)

const FONT_TITLE = preload("res://Assets/fonts/UrbanRiotDEMO-B85.ttf")
const FONT_TEXT = preload("res://Assets/fonts/Urbana-®.ttf")
const FONT_DIGITAL = preload("res://Assets/fonts/DS-DIGI.TTF")

@export var leaderboard_internal_name: String = ""
@export var include_archived: bool

@onready var leaderboard_name: Label = %LeaderboardName
@onready var entries_container: VBoxContainer = %Entries
@onready var info_label: Label = %InfoLabel
@onready var username: TextEdit = %Username
@onready var filter_button: Button = %Filter
@onready var btn_submit: Button = $UI/MarginContainer/VBoxContainer/Submit
@onready var btn_retry: Button = $UI/MarginContainer/VBoxContainer/rety
@onready var btn_exit: Button = $UI/MarginContainer/VBoxContainer/exit

var _entries_error: bool
var _filter: String = "All"
var _filter_idx: int

func _ready() -> void:
	_setup_ui_style()
	
	leaderboard_name.text = leaderboard_name.text.replace("{leaderboard}", "BEST PLAYERS")
	await _load_entries()
	_set_entry_count()

func _setup_ui_style() -> void:
	leaderboard_name.add_theme_font_override("font", FONT_TITLE)
	leaderboard_name.add_theme_font_size_override("font_size", 72)
	leaderboard_name.add_theme_color_override("font_color", Color(1, 0.2, 0.4))
	
	info_label.add_theme_font_override("font", FONT_TEXT)
	info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	
	username.add_theme_font_override("font", FONT_TEXT)
	
	for btn in [btn_submit, filter_button, btn_retry, btn_exit]:
		if btn:
			_style_button(btn)

func _style_button(btn: Button) -> void:
	btn.add_theme_font_override("font", FONT_TITLE)
	btn.add_theme_font_size_override("font_size", 32)
	btn.flat = false

func _set_entry_count():
	if entries_container.get_child_count() == 0:
		info_label.text = "Be the first playing!" if not _entries_error else "Error loading data."
	else:
		info_label.text = ""

func _create_entry(entry: TaloLeaderboardEntry, index: int) -> void:
	var panel = PanelContainer.new()
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.6)
	style_box.set_corner_radius_all(10)
	style_box.content_margin_left = 20
	style_box.content_margin_right = 20
	style_box.content_margin_top = 10
	style_box.content_margin_bottom = 10
	
	panel.add_theme_stylebox_override("panel", style_box)
	
	var hbox = HBoxContainer.new()
	panel.add_child(hbox)
	
	var lbl_rank = Label.new()
	lbl_rank.text = "#%d" % (entry.position + 1)
	lbl_rank.custom_minimum_size.x = 80
	lbl_rank.add_theme_font_override("font", FONT_DIGITAL)
	lbl_rank.add_theme_font_size_override("font_size", 40)
	
	if entry.position == 0: lbl_rank.modulate = COLOR_ORO
	elif entry.position == 1: lbl_rank.modulate = COLOR_PLATA
	elif entry.position == 2: lbl_rank.modulate = COLOR_BRONCE
	else: lbl_rank.modulate = Color(0.5, 0.5, 0.5)
	
	hbox.add_child(lbl_rank)
	
	var lbl_name = Label.new()
	lbl_name.text = entry.player_alias.identifier
	lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL 
	lbl_name.add_theme_font_override("font", FONT_TEXT)
	lbl_name.add_theme_font_size_override("font_size", 32)
	lbl_name.modulate = COLOR_TEXTO
	hbox.add_child(lbl_name)
	
	var team = entry.get_prop("team", "")
	if not team.is_empty():
		var lbl_team = Label.new()
		lbl_team.text = "[%s]" % team
		lbl_team.add_theme_font_override("font", FONT_TEXT)
		lbl_team.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
		lbl_team.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		hbox.add_child(lbl_team)
		
		var spacer = Control.new()
		spacer.custom_minimum_size.x = 20
		hbox.add_child(spacer)

	var lbl_score = Label.new()
	lbl_score.text = str(int(entry.score))
	lbl_score.add_theme_font_override("font", FONT_DIGITAL)
	lbl_score.add_theme_font_size_override("font_size", 48)
	lbl_score.add_theme_color_override("font_color", COLOR_SCORE)
	lbl_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hbox.add_child(lbl_score)
	
	entries_container.add_child(panel)
	
	panel.modulate.a = 0.0
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3).set_delay(index * 0.05)
	
func _build_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()

	var entries = Talo.leaderboards.get_cached_entries(leaderboard_internal_name)
	if _filter != "All":
		entries = entries.filter(func (entry: TaloLeaderboardEntry): return entry.get_prop("team", "") == _filter)

	for i in range(entries.size()):
		var entry = entries[i]
		_create_entry(entry, i)

func _load_entries() -> void:
	var page := 0
	var done := false
	
	info_label.text = "Cargando..."
	
	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page
		options.include_archived = include_archived

		var res := await Talo.leaderboards.get_entries(leaderboard_internal_name, options)

		if not is_instance_valid(res):
			_entries_error = true
			info_label.text = "Network error"
			return

		var entries := res.entries
		var is_last_page := res.is_last_page

		if is_last_page:
			done = true
		else:
			page += 1

	_build_entries()

func _on_submit_pressed() -> void:
	var name := username.text.strip_edges()
	if name.is_empty():
		info_label.text = "Enter your name!"
		return

	if Global.last_score <= 0:
		info_label.text = "There is no new score."
		return
	
	btn_submit.disabled = true
	info_label.text = "Sending..."

	await Talo.players.identify("username", name)

	var score := Global.last_score
	var res := await Talo.leaderboards.add_entry(leaderboard_internal_name, score, {})
	assert(is_instance_valid(res))

	info_label.text = "¡%s Points!" % score
	if res.updated:
		info_label.text += "\n¡NEW RECORDs!"

	await _load_entries()
	_set_entry_count()

	Global.last_score = 0
	btn_submit.disabled = false
	username.editable = false

func _get_next_filter(idx: int) -> String:
	return ["All", "Blue", "Red"][idx % 3]

func _on_filter_pressed() -> void:
	_filter_idx += 1
	_filter = _get_next_filter(_filter_idx)

	info_label.text = "Filtro: %s" % _filter
	filter_button.text = "Ver equipo %s" % _get_next_filter(_filter_idx + 1)

	_build_entries()

func _on_rety_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
