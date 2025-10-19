import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Mini Player Widget - Compact player shown at bottom of main screens
class MiniPlayerMusium extends StatefulWidget {
  final String songTitle;
  final String artistName;
  final VoidCallback onTap;
  final VoidCallback? onPlayPause;
  final bool isPlaying;

  const MiniPlayerMusium({
    Key? key,
    required this.songTitle,
    required this.artistName,
    required this.onTap,
    this.onPlayPause,
    this.isPlaying = true,
  }) : super(key: key);

  @override
  State<MiniPlayerMusium> createState() => _MiniPlayerMusiumState();
}

class _MiniPlayerMusiumState extends State<MiniPlayerMusium>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    if (widget.isPlaying) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(MiniPlayerMusium oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!widget.isPlaying && _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorMusium.darkSurfaceLight,
              AppColorMusium.darkSurface,
            ],
          ),
          border: Border.all(
            color: AppColorMusium.accentTeal.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColorMusium.accentTeal.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Album art (rotating)
            RotationTransition(
              turns: _animationController,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorMusium.accentTeal,
                      AppColorMusium.accentPurple,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.music_note,
                  size: 24,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Song info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.songTitle,
                    style: AppTypographyMusium.bodySmall.copyWith(
                      color: AppColorMusium.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.artistName,
                    style: AppTypographyMusium.bodySmall.copyWith(
                      color: AppColorMusium.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Play/Pause button
            GestureDetector(
              onTap: widget.onPlayPause,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColorMusium.accentTeal.withValues(alpha: 0.2),
                ),
                child: Icon(
                  widget.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColorMusium.accentTeal,
                  size: 18,
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Next button
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColorMusium.accentTeal.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.skip_next,
                  color: AppColorMusium.accentTeal,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
