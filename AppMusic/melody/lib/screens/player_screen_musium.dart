import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Full Screen Player with Controls & Visualizer
class PlayerScreenMusium extends StatefulWidget {
  const PlayerScreenMusium({Key? key}) : super(key: key);

  @override
  State<PlayerScreenMusium> createState() => _PlayerScreenMusiumState();
}

class _PlayerScreenMusiumState extends State<PlayerScreenMusium>
    with TickerProviderStateMixin {
  bool isPlaying = true;
  bool isFavorite = false;
  double playbackPosition = 0.65;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorMusium.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColorMusium.darkSurface,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.expand_more,
                        color: AppColorMusium.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    'Now Playing',
                    style: AppTypographyMusium.labelLarge.copyWith(
                      color: AppColorMusium.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColorMusium.darkSurface,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.more_vert,
                        color: AppColorMusium.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Album Art with Visualizer
            Expanded(
              flex: 2,
              child: Center(
                child: RotationTransition(
                  turns: _animationController,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColorMusium.accentTeal,
                          AppColorMusium.accentPurple,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColorMusium.accentTeal.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.music_note,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Track Info
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Beautiful Song Title',
                              style: AppTypographyMusium.heading4.copyWith(
                                color: AppColorMusium.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Amazing Artist',
                              style: AppTypographyMusium.bodyMedium.copyWith(
                                color: AppColorMusium.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => isFavorite = !isFavorite);
                          },
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? AppColorMusium.error
                                : AppColorMusium.textSecondary,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColorMusium.accentTeal,
                      inactiveTrackColor:
                          AppColorMusium.textTertiary.withValues(alpha: 0.2),
                      thumbColor: AppColorMusium.accentTeal,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: playbackPosition,
                      onChanged: (value) {
                        setState(() => playbackPosition = value);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '2:35',
                        style: AppTypographyMusium.bodySmall.copyWith(
                          color: AppColorMusium.textTertiary,
                        ),
                      ),
                      Text(
                        '4:00',
                        style: AppTypographyMusium.bodySmall.copyWith(
                          color: AppColorMusium.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _controlButton(Icons.shuffle, () {}, false),
                  _controlButton(Icons.skip_previous, () {}, false, size: 40),
                  _playPauseButton(),
                  _controlButton(Icons.skip_next, () {}, false, size: 40),
                  _controlButton(Icons.repeat, () {}, false),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Queue Preview
            Container(
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColorMusium.darkSurfaceLight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Up Next',
                    style: AppTypographyMusium.labelLarge.copyWith(
                      color: AppColorMusium.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: 2,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: AppColorMusium.accentTeal
                                    .withValues(alpha: 0.2),
                              ),
                              child: Icon(
                                Icons.music_note,
                                size: 18,
                                color: AppColorMusium.accentTeal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Next Song ${index + 1}',
                                    style:
                                        AppTypographyMusium.bodySmall.copyWith(
                                      color: AppColorMusium.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Artist Name',
                                    style:
                                        AppTypographyMusium.bodySmall.copyWith(
                                      color: AppColorMusium.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onTap, bool isActive,
      {double size = 32}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size + 12,
        height: size + 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? AppColorMusium.accentTeal.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: size,
          color: isActive
              ? AppColorMusium.accentTeal
              : AppColorMusium.textSecondary,
        ),
      ),
    );
  }

  Widget _playPauseButton() {
    return GestureDetector(
      onTap: () {
        setState(() => isPlaying = !isPlaying);
        if (isPlaying) {
          _animationController.forward();
        } else {
          _animationController.stop();
        }
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColorMusium.accentTeal,
              AppColorMusium.accentPurple,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColorMusium.accentTeal.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }
}
