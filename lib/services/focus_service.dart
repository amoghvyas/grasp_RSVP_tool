import 'package:just_audio/just_audio.dart';

enum FocusSound {
  none('None', null),
  brownNoise('Deep Focus', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'), // Using public domain placeholders
  rain('Gentle Rain', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'),
  lofi('Lofi Study', 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3');

  final String label;
  final String? url;
  const FocusSound(this.label, this.url);
}

/// Service to handle ambient focus sounds.
class FocusService {
  final _player = AudioPlayer();
  FocusSound _currentSound = FocusSound.none;

  FocusSound get current => _currentSound;

  Future<void> setSound(FocusSound sound) async {
    if (_currentSound == sound) return;
    
    await _player.stop();
    _currentSound = sound;

    if (sound.url != null) {
      try {
        await _player.setUrl(sound.url!);
        await _player.setLoopMode(LoopMode.one);
        await _player.play();
      } catch (e) {
        // Silent fail if network issue
      }
    }
  }

  void setVolume(double volume) {
    _player.setVolume(volume);
  }

  void dispose() {
    _player.dispose();
  }
}
