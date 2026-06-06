extends Node2D
## 语音交互组件 — sherpa-onnx 实时语音识别

signal voice_command(text: String)
signal voice_partial(text: String)
signal asr_ready()
signal asr_error(message: String)

@export var model_dir: String = "res://models/sherpa-asr/sherpa-onnx-streaming-zipformer-bilingual-zh-en-2023-02-20"
@export var audio_bus: String = "MicroRecorder"
@export var debug_log: bool = true

var _asr: SherpaASR
var _capture: AudioEffectCapture
var _mic_stream: AudioStreamMicrophone
var _mic_player: AudioStreamPlayer

var _last_text: String = ""
var _cooldown: int = 0
var _fired: bool = false


func _ready():
	_asr = $SherpaASR if has_node("SherpaASR") else null
	if _asr == null:
		for child in get_children():
			if child is SherpaASR:
				_asr = child
				break
	if _asr == null:
		asr_error.emit("未找到 SherpaASR 子节点！")
		set_process(false)
		return

	_mic_stream = AudioStreamMicrophone.new()
	_mic_player = AudioStreamPlayer.new()
	_mic_player.stream = _mic_stream
	_mic_player.bus = audio_bus
	_mic_player.volume_db = 0.0
	add_child(_mic_player)
	_mic_player.play()

	var bus_idx = AudioServer.get_bus_index(audio_bus)
	if bus_idx == -1:
		asr_error.emit("音频总线不存在: " + audio_bus)
		set_process(false)
		return
	for i in range(AudioServer.get_bus_effect_count(bus_idx)):
		var fx = AudioServer.get_bus_effect(bus_idx, i)
		if fx is AudioEffectCapture:
			_capture = fx
			break
	if _capture == null:
		asr_error.emit("总线上没有 AudioEffectCapture！")
		set_process(false)
		return

	var real_path = ProjectSettings.globalize_path(model_dir)
	_asr.model_dir = real_path
	_asr.set_rule1_min_trailing_silence(0.5)
	_asr.set_rule2_min_trailing_silence(0.3)
	if not _asr.initialize():
		asr_error.emit("ASR 初始化失败")
		set_process(false)
		return

	if debug_log:
		print("[语音交互] 就绪")
	asr_ready.emit()


func _process(_delta):
	if _asr == null or not _asr.is_initialized() or _capture == null:
		return

	var frames = _capture.get_frames_available()
	if frames <= 0:
		return

	var stereo = _capture.get_buffer(frames)
	var mono = _resample(stereo)
	if mono.size() <= 0:
		return

	# 冷却期只丢弃音频
	if _cooldown > 0:
		_cooldown -= 1
		return

	_asr.accept_waveform(mono, 16000)
	_asr.decode()
	var text = _asr.get_result().strip_edges()

	# 文本更新
	if text != _last_text:
		if text.length() > 0:
			if debug_log:
				print("💬 [语音交互]: ", text)
			voice_partial.emit(text)
		_last_text = text
		_fired = false

	# 端点检测触发（仅触发一次，直到有新文本）
	if _asr.is_endpoint() and text.length() >= 1 and not _fired:
		if debug_log:
			print("📝 [语音交互]: ", text)
		voice_command.emit(text)
		_fired = true
		_asr.input_finished()
		_asr.reset_stream()
		_last_text = ""
		_cooldown = 20  # ~0.3s 冷却，彻底清空残留


func _resample(stereo: PackedVector2Array) -> PackedFloat32Array:
	var ratio := 44100.0 / 16000.0
	var out_size := int(stereo.size() / ratio)
	if out_size < 1:
		return PackedFloat32Array()
	var result := PackedFloat32Array()
	result.resize(out_size)
	for i in range(out_size):
		var src: float = i * ratio
		var idx: int = int(src)
		var frac: float = src - float(idx)
		var a: float = stereo[idx].x
		var b: float = stereo[idx + 1].x if idx + 1 < stereo.size() else a
		result[i] = clampf(lerpf(a, b, frac) * 30.0, -1.0, 1.0)
	return result


func is_listening() -> bool:
	return _asr != null and _asr.is_initialized()
