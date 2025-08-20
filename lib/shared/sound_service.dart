// lib/shared/sound_service.dart
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  // ========= STATE =========
  final AudioPlayer _bgm = AudioPlayer();
  AudioPool? _tapPool;
  AudioPool? _correctPool;
  AudioPool? _wrongPool;

  // Penting: cache tanpa prefix supaya path "asset/..." tidak ditambah "assets/"
  final AudioCache _cacheNoPrefix = AudioCache(prefix: '');

  bool _muted = false;
  double _bgmVol = 0.35; // 0..1
  double _sfxVol = 0.80; // 0..1

  // ========= INIT =========
  Future<void> init() async {
    await _bgm.setReleaseMode(ReleaseMode.loop);

    // Pools SFX
    _tapPool ??= await AudioPool.create(
      source: AssetSource('asset/sounds/sfx_tap.mp3'),
      maxPlayers: 3,
      minPlayers: 1,
      audioCache: _cacheNoPrefix,
    );
    _correctPool ??= await AudioPool.create(
      source: AssetSource('asset/sounds/sfx_correct.mp3'),
      maxPlayers: 2,
      minPlayers: 1,
      audioCache: _cacheNoPrefix,
    );
    _wrongPool ??= await AudioPool.create(
      source: AssetSource('asset/sounds/sfx_wrong.mp3'),
      maxPlayers: 2,
      minPlayers: 1,
      audioCache: _cacheNoPrefix,
    );
  }

  static Future<void> warmup() => instance.init();

  // ========= BGM (pakai BytesSource agar TIDAK kena prefix "assets/") =========
  Future<void> _playBgmFromAsset(String path) async {
    if (_muted) return;
    try {
      // Muat sebagai bytes via cache tanpa prefix
      final bytes = await _cacheNoPrefix.loadAsBytes(path);
      await _bgm.stop();
      await _bgm.setVolume(_bgmVol);
      await _bgm.play(BytesSource(bytes));
    } catch (e) {
      // Bantu debug kalau path salah
      // ignore: avoid_print
      print('BGM load error for "$path": $e');
      rethrow;
    }
  }

  Future<void> playMenuBgm() => _playBgmFromAsset('asset/sounds/bgm_menu.mp3');

  Future<void> playExerciseBgm() =>
      _playBgmFromAsset('asset/sounds/bgm_exercise.mp3');

  Future<void> stopBgm() => _bgm.stop();

  Future<void> fadeOutBgm({
    Duration dur = const Duration(milliseconds: 300),
  }) async {
    final steps = 8;
    final stepVol = _bgmVol / steps;
    final stepDur = dur ~/ steps;
    for (int i = 0; i < steps; i++) {
      final v = (_bgmVol - (i + 1) * stepVol).clamp(0.0, 1.0);
      await _bgm.setVolume(v);
      await Future.delayed(stepDur);
    }
    await _bgm.stop();
    await _bgm.setVolume(_bgmVol);
  }

  // ========= SFX =========
  void tap() {
    if (!_muted) _tapPool?.start(volume: _sfxVol);
  }

  void correct() {
    if (!_muted) _correctPool?.start(volume: _sfxVol);
  }

  void wrong() {
    if (!_muted) _wrongPool?.start(volume: _sfxVol);
  }

  // ========= Controls =========
  void setMuted(bool v) {
    _muted = v;
    _bgm.setVolume(v ? 0 : _bgmVol);
  }

  void setVolumes({double? bgm, double? sfx}) {
    if (bgm != null) {
      _bgmVol = bgm.clamp(0.0, 1.0);
      _bgm.setVolume(_muted ? 0 : _bgmVol);
    }
    if (sfx != null) {
      _sfxVol = sfx.clamp(0.0, 1.0);
    }
  }

  Future<void> dispose() async {
    await _bgm.dispose();
    await _tapPool?.dispose();
    await _correctPool?.dispose();
    await _wrongPool?.dispose();
  }
}
