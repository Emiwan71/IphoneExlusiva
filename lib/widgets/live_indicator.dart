import 'package:flutter/material.dart';

class LiveIndicator extends StatefulWidget {
  final bool isLive;

  const LiveIndicator({super.key, this.isLive = true});

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isLive
              ? Colors.redAccent.withValues(alpha: 0.6)
              : Colors.white24,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isLive
                ? Colors.red.withValues(alpha: 0.3)
                : Colors.transparent,
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: widget.isLive ? _pulseAnimation.value : 0.4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isLive ? const Color(0xFFFF2D55) : Colors.grey,
                    boxShadow: widget.isLive
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF2D55)
                                  .withValues(alpha: _pulseAnimation.value),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            widget.isLive ? 'EN VIVO' : 'DISCONECTADO',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
