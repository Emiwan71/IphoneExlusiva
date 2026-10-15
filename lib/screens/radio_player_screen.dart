import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/live_indicator.dart';
import '../widgets/volume_slider.dart';

class RadioPlayerScreen extends StatefulWidget {
  const RadioPlayerScreen({super.key});

  @override
  State<RadioPlayerScreen> createState() => _RadioPlayerScreenState();
}

class _RadioPlayerScreenState extends State<RadioPlayerScreen>
    with SingleTickerProviderStateMixin {
  static const String streamUrl =
      'https://audio.streaminghd.cl:9148/stream/;stream.mp3';
  static const String fallbackLogoUrl =
      'https://fmexclusiva.cl/assets/img/home/logo-radio.webp';
  static const String fallbackBgUrl =
      'https://fmexclusiva.cl/assets/img/gallery/6a090625619ba_1778976293.webp';

  static const Map<String, String> _networkHeaders = {
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
  };

  late AudioPlayer _audioPlayer;
  double _volume = 0.8;
  double _previousVolume = 0.8;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    try {
      await _audioPlayer.setVolume(_volume);
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isLoading = state.processingState == ProcessingState.loading ||
                state.processingState == ProcessingState.buffering;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Error de conexión con el streaming';
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });
    }

    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      } else {
        setState(() {
          _isLoading = true;
        });
        await _audioPlayer.setUrl(streamUrl);
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'No se pudo conectar a la transmisión en vivo.';
        });
      }
    }
  }

  void _onVolumeChanged(double value) {
    setState(() {
      _volume = value;
    });
    _audioPlayer.setVolume(value);
  }

  void _toggleMute() {
    if (_volume > 0) {
      _previousVolume = _volume;
      _onVolumeChanged(0);
    } else {
      _onVolumeChanged(_previousVolume > 0 ? _previousVolume : 0.8);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image with Dark Gradient & Blur
          Image.asset(
            'assets/logo_exclusiva.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => CachedNetworkImage(
              imageUrl: fallbackBgUrl,
              httpHeaders: _networkHeaders,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.black),
              errorWidget: (context, url, error) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A0A0A), Color(0xFF000000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // 2. Overlay Blur & Darkening Gradient for Neon Backdrop
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.82),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 3. Main Content View
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Header with Live Badge
                  Padding(
                    padding: EdgeInsets.only(top: padding.top > 0 ? 8 : 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'RADIO STREAMING',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        StreamBuilder<bool>(
                          stream: _audioPlayer.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;
                            return LiveIndicator(isLive: isPlaying);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Middle Section: Logo & Station Information
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Radio Logo inside Glass Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: size.width * 0.72,
                            height: size.width * 0.72,
                            constraints: const BoxConstraints(
                              maxWidth: 300,
                              maxHeight: 300,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: const Color(0xFFFF2D55)
                                    .withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF2D55)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 35,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/logo_exclusiva.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.network(
                                  fallbackLogoUrl,
                                  headers: _networkHeaders,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons
                                            .antenna_radiowaves_left_right,
                                        size: 60,
                                        color: Colors.white70,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'FM EXCLUSIVA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Station Name
                      const Text(
                        'FM EXCLUSIVA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Subtitle Phrase
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Exclusiva FM - 90.9 Mhz Talca - 93.3 Mhz Curicó',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Audio Visualizer Equalizer
                      StreamBuilder<bool>(
                        stream: _audioPlayer.playingStream,
                        builder: (context, snapshot) {
                          final isPlaying = snapshot.data ?? false;
                          return AudioVisualizer(isPlaying: isPlaying);
                        },
                      ),
                    ],
                  ),

                  // Bottom Controls Section
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_hasError)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Color(0xFFFF453A),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Play / Pause Button with Glow & Pulse Effect
                      StreamBuilder<bool>(
                        stream: _audioPlayer.playingStream,
                        builder: (context, snapshot) {
                          final isPlaying = snapshot.data ?? false;

                          return GestureDetector(
                            onTap: _togglePlayPause,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF3B30),
                                    Color(0xFFFF2D55),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF2D55).withValues(
                                      alpha: isPlaying ? 0.6 : 0.3,
                                    ),
                                    blurRadius: isPlaying ? 25 : 15,
                                    spreadRadius: isPlaying ? 4 : 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const CupertinoActivityIndicator(
                                        color: Colors.white,
                                        radius: 18,
                                      )
                                    : Icon(
                                        isPlaying
                                            ? CupertinoIcons.pause_fill
                                            : CupertinoIcons.play_fill,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // Volume Slider Control
                      VolumeSlider(
                        volume: _volume,
                        onChanged: _onVolumeChanged,
                        onMuteToggle: _toggleMute,
                      ),

                      SizedBox(height: padding.bottom > 0 ? 12 : 24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
