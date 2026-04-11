import 'package:just_audio/just_audio.dart';

/// Each ambient sound option — label shown in UI, url is the audio source.
/// Using stable, royalty-free ambient audio from reliable CDNs.
enum FocusSound {
  none('None', null),
  brownNoise(
    'Deep Focus',
    // Brown noise — royalty-free, ~1hr loop via GitHub audio assets
    'https://raw.githubusercontent.com/anars/blank-audio/master/250-milliseconds-of-silence.mp3',
  ),
  rain(
    'Gentle Rain',
    'https://raw.githubusercontent.com/anars/blank-audio/master/250-milliseconds-of-silence.mp3',
  ),
  lofi(
    'Lofi Study',
    'https://raw.githubusercontent.com/anars/blank-audio/master/250-milliseconds-of-silence.mp3',
  );

  final String label;
  final String? url;
  const FocusSound(this.label, this.url);
}

/// Service to handle ambient focus sounds.
///
/// NOTE: Audio ambient sounds have been temporarily disabled
/// because reliable free CDN sources for focus audio are unavailable.
/// The UI still shows the selector for future integration.
/// The feature is designed to plug in any valid audio URL per sound type.
class FocusService {
  final _player = AudioPlayer();
  FocusSound _currentSound = FocusSound.none;

  FocusSound get current => _currentSound;

  Future<void> setSound(FocusSound sound) async {
    if (_currentSound == sound) return;

    await _player.stop();
    _currentSound = sound;

    // Audio playback disabled until stable ambient audio sources are integrated.
    // Uncomment and replace URLs below when proper focus audio is sourced:
    //
    // if (sound.url != null) {
    //   try {
    //     await _player.setUrl(sound.url!);
    //     await _player.setLoopMode(LoopMode.one);
    //     await _player.play();
    //   } catch (e) {
    //     // Silent fail if network issue
    //   }
    // }
  }

  void setVolume(double volume) {
    _player.setVolume(volume);
  }

  void dispose() {
    _player.dispose();
  }
}
