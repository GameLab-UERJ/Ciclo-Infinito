extends Node
var music_player := AudioStreamPlayer.new()

func _ready() -> void:
	add_child(music_player)

func play_music(stream: AudioStream):
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.play()

func stop_music():
	music_player.stop()
