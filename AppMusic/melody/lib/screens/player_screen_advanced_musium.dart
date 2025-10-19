import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';
import 'package:melody/widgets/visualizer_musium.dart';
import 'package:melody/widgets/modals/equalizer_modal_musium.dart';
import 'package:melody/widgets/modals/sleep_timer_modal_musium.dart';

/// Advanced Player Screen with Visualizer & Enhanced Controls
class PlayerScreenAdvancedMusium extends StatefulWidget {
  const PlayerScreenAdvancedMusium({Key? key}) : super(key: key);

  @override
  State<PlayerScreenAdvancedMusium> createState() =>
      _PlayerScreenAdvancedMusiumState();
}

class _PlayerScreenAdvancedMusiumState extends State<PlayerScreenAdvancedMusium>
    with TickerProviderStateMixin {
  bool isPlaying = true;
  bool isFavorite = false;
  double playbackPosition = 0.65;
  int sleepTimerMinutes = 0;
  int selectedViewMode = 0; // 0: Visualizer, 1: Album Art, 2: Lyrics
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
            // Header with controls
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
                    onTap: () => showEqualizerModal(context),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColorMusium.darkSurface,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.tune,
                        color: AppColorMusium.accentTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // View Mode Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildViewModeButton(0, Icons.show_chart, 'Visualizer'),
                  const SizedBox(width: 12),
                  _buildViewModeButton(1, Icons.album, 'Album'),
                  const SizedBox(width: 12),
                  _buildViewModeButton(2, Icons.notes, 'Lyrics'),
                ],
              ),
            ),

            // Main Content Area (Visualizer/Album/Lyrics)
            Expanded(
              flex: 2,
              child: Center(
                child: _buildMainContent(),
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
                  _controlButton(
                    Icons.timer,
                    () => _showSleepTimerDialog(),
                    sleepTimerMinutes > 0,
                  ),
                ],
              ),
            ),

            // Sleep Timer Status
            if (sleepTimerMinutes > 0)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppColorMusium.accentTeal.withValues(alpha: 0.2),
                    border: Border.all(
                      color: AppColorMusium.accentTeal,
                    ),
                  ),
                  child: Text(
                    '⏱️ Sleep timer: ${sleepTimerMinutes}m',
                    style: AppTypographyMusium.bodySmall.copyWith(
                      color: AppColorMusium.accentTeal,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 12),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeButton(int index, IconData icon, String label) {
    final isSelected = selectedViewMode == index;
    return GestureDetector(
      onTap: () => setState(() => selectedViewMode = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppColorMusium.accentTeal
              : AppColorMusium.darkSurface,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColorMusium.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypographyMusium.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColorMusium.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (selectedViewMode) {
      case 0:
        // Visualizer view
        return Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: VisualizerMusium(
            isPlaying: isPlaying,
            barCount: 20,
          ),
        );
      case 1:
        // Album art view
        return RotationTransition(
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
                  color: AppColorMusium.accentTeal.withValues(alpha: 0.4),
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
        );
      case 2:
        // Lyrics view
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lyrics will appear here',
                textAlign: TextAlign.center,
                style: AppTypographyMusium.heading4.copyWith(
                  color: AppColorMusium.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Synchronized lyrics powered by your music service',
                textAlign: TextAlign.center,
                style: AppTypographyMusium.bodyMedium.copyWith(
                  color: AppColorMusium.textSecondary,
                ),
              ),
            ],
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  void _showSleepTimerDialog() async {
    final result = await showSleepTimerModal(context);
    if (result != null) {
      setState(() => sleepTimerMinutes = result);
    }
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
