import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  double _volume = 0.3;
  bool _isInitialized = false;
  bool _isBgmPlaying = false; // Track BGM state

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  double get volume => _volume;

  Future<void> init() async {
    if (_isInitialized) return;

    // Load preferences
    final prefs = await SharedPreferences.getInstance();
    _isMusicEnabled = prefs.getBool('music_enabled') ?? true;
    _isSfxEnabled = prefs.getBool('sfx_enabled') ?? true;
    _volume = prefs.getDouble('volume') ?? 0.3;

    // Configure BGM player - MUSIC mode untuk main audio
    await _bgmPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_volume);

    // CRITICAL: Set audio context untuk BGM agar tidak di-stop oleh SFX
    await _bgmPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain, // GAIN focus untuk BGM
        ),
      ),
    );

    // Configure SFX player - NOTIFICATION/GAME mode
    await _sfxPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _sfxPlayer.setReleaseMode(ReleaseMode.release);
    await _sfxPlayer.setVolume(_volume * 1.5);

    // CRITICAL: Set SFX to NOT steal focus from BGM
    // NOTE: category harus playback/playAndRecord/multiRoute kalau mau pakai
    // mixWithOthers, jadi jangan pakai `ambient` di sini (itu penyebab crash-nya).
    await _sfxPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus
              .gainTransient, // Transient, tidak ambil full focus
        ),
      ),
    );

    // Listen to BGM player state changes
    _bgmPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        // BGM stopped unexpectedly, restart if enabled
        if (_isMusicEnabled && _isBgmPlaying) {
          print('BGM stopped unexpectedly, restarting...');
          playBGM();
        }
      }
    });

    _isInitialized = true;

    // Auto-play BGM if enabled
    if (_isMusicEnabled) {
      await playBGM();
    }
  }

  Future<void> playBGM() async {
    if (!_isMusicEnabled) return;

    try {
      _isBgmPlaying = true;
      await _bgmPlayer.play(AssetSource('audio/bgm_traditional.mp3'));
    } catch (e) {
      print('Error playing BGM: $e');
      _isBgmPlaying = false;
    }
  }

  Future<void> pauseBGM() async {
    _isBgmPlaying = false;
    await _bgmPlayer.pause();
  }

  Future<void> resumeBGM() async {
    if (_isMusicEnabled) {
      _isBgmPlaying = true;
      await _bgmPlayer.resume();
    }
  }

  Future<void> stopBGM() async {
    _isBgmPlaying = false;
    await _bgmPlayer.stop();
  }

  // Helper to ensure BGM is playing (called after SFX)
  Future<void> ensureBGMPlaying() async {
    if (_isMusicEnabled && !_isBgmPlaying) {
      await playBGM();
    } else if (_isMusicEnabled) {
      // Check if actually playing
      final state = _bgmPlayer.state;
      if (state != PlayerState.playing) {
        await playBGM();
      }
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _bgmPlayer.setVolume(_volume);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', _volume);
  }

  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', _isMusicEnabled);

    if (_isMusicEnabled) {
      await playBGM();
    } else {
      await pauseBGM();
    }
  }

  Future<void> toggleSfx() async {
    _isSfxEnabled = !_isSfxEnabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfx_enabled', _isSfxEnabled);
  }

  Future<void> playCorrectSound() async {
    if (!_isSfxEnabled) return;

    try {
      // Just play, don't stop or check BGM (let them be independent)
      _sfxPlayer.play(AssetSource('audio/correct.mp3'));
    } catch (e) {
      print('Error playing correct sound: $e');
    }
  }

  Future<void> playWrongSound() async {
    if (!_isSfxEnabled) return;

    try {
      // Just play, don't stop or check BGM (let them be independent)
      _sfxPlayer.play(AssetSource('audio/wrong.mp3'));
    } catch (e) {
      print('Error playing wrong sound: $e');
    }
  }

  Future<void> playCompleteSound() async {
    if (!_isSfxEnabled) return;

    try {
      // Just play, don't stop or check BGM (let them be independent)
      _sfxPlayer.play(AssetSource('audio/complete.mp3'));
    } catch (e) {
      print('Error playing complete sound: $e');
    }
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}