import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VolumeSlider extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onChanged;
  final VoidCallback onMuteToggle;

  const VolumeSlider({
    super.key,
    required this.volume,
    required this.onChanged,
    required this.onMuteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onMuteToggle,
                child: Icon(
                  volume == 0
                      ? CupertinoIcons.volume_off
                      : volume < 0.5
                          ? CupertinoIcons.volume_down
                          : CupertinoIcons.volume_up,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: const SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: Color(0xFFFF3B30),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                      elevation: 4,
                    ),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                  ),
                  child: Slider(
                    value: volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: onChanged,
                  ),
                ),
              ),
              Text(
                '${(volume * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
