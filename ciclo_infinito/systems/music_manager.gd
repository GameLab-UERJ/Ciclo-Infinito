extends Node
var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	add_child(music_player)

func play_music(stream: AudioStream, from_sec: float = 0.0) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.play(from_sec)

func stop_music() -> void:
	music_player.stop()
