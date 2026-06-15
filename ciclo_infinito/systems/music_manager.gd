extends Node


var music_player: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready() -> void:
	add_child(music_player)


func play_music(stream: AudioStream, 
				from_sec: float = 0.0, 
				starting_volume_db: float = 0.0, 
				fade_in: bool = true) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.volume_db = -80
	if fade_in:
		create_tween().tween_property(music_player,"volume_db",starting_volume_db,2)
	else:
		music_player.volume_db = starting_volume_db
	music_player.play(from_sec)


func increase_volume(amount: float = 0.0) -> void:
	if not music_player:
		return
	create_tween().tween_property(music_player,"volume_db",music_player.volume_db + amount,1)


func stop_music(fade_out_time : float = 0) -> void:
	if fade_out_time > 0:
		await create_tween().tween_property(music_player,"volume_db",-30,fade_out_time).finished
	music_player.stop()


func is_playing() -> bool:
	return music_player.is_playing()
