import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Sleep Timer Modal
class SleepTimerModalMusium extends StatefulWidget {
  const SleepTimerModalMusium({Key? key}) : super(key: key);

  @override
  State<SleepTimerModalMusium> createState() => _SleepTimerModalMusiumState();
}

class _SleepTimerModalMusiumState extends State<SleepTimerModalMusium> {
  int selectedMinutes = 0;
  final List<int> presetTimes = [5, 10, 15, 30, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorMusium.darkBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: AppColorMusium.textTertiary.withValues(alpha: 0.3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sleep Timer',
                  style: AppTypographyMusium.heading4.copyWith(
                    color: AppColorMusium.accentTeal,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    color: AppColorMusium.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColorMusium.textTertiary, height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // Timer display
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Text(
                        _formatTime(selectedMinutes),
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: AppColorMusium.accentTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedMinutes == 0
                            ? 'No timer set'
                            : 'Timer will stop music',
                        style: AppTypographyMusium.bodyMedium.copyWith(
                          color: AppColorMusium.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Preset times
                Text(
                  'Quick Select',
                  style: AppTypographyMusium.heading5.copyWith(
                    color: AppColorMusium.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: presetTimes.length,
                  itemBuilder: (context, index) {
                    final minutes = presetTimes[index];
                    final isSelected = selectedMinutes == minutes;
                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedMinutes = minutes);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected
                              ? AppColorMusium.accentTeal
                              : AppColorMusium.darkSurfaceLight,
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: AppColorMusium.textTertiary
                                      .withValues(alpha: 0.3),
                                ),
                        ),
                        child: Center(
                          child: Text(
                            '${minutes}m',
                            style: AppTypographyMusium.bodyMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColorMusium.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Custom time section
                Text(
                  'Custom Time',
                  style: AppTypographyMusium.heading5.copyWith(
                    color: AppColorMusium.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Time picker
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColorMusium.darkSurfaceLight,
                  ),
                  child: Column(
                    children: [
                      Slider(
                        value: selectedMinutes.toDouble(),
                        min: 0,
                        max: 240,
                        divisions: 240,
                        activeColor: AppColorMusium.accentTeal,
                        inactiveColor:
                            AppColorMusium.textTertiary.withValues(alpha: 0.2),
                        onChanged: (value) {
                          setState(() => selectedMinutes = value.toInt());
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Minutes',
                            style: AppTypographyMusium.bodySmall.copyWith(
                              color: AppColorMusium.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: AppColorMusium.darkBg,
                            ),
                            child: Text(
                              '${selectedMinutes}',
                              style: AppTypographyMusium.bodyMedium.copyWith(
                                color: AppColorMusium.accentTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColorMusium.textSecondary,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: AppTypographyMusium.labelLarge.copyWith(
                                  color: AppColorMusium.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Set timer
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: selectedMinutes == 0
                                ? [
                                    AppColorMusium.textTertiary,
                                    AppColorMusium.textTertiary,
                                  ]
                                : [
                                    AppColorMusium.accentTeal,
                                    AppColorMusium.accentPurple,
                                  ],
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: selectedMinutes == 0
                                ? null
                                : () {
                                    Navigator.pop(context, selectedMinutes);
                                  },
                            child: Center(
                              child: Text(
                                selectedMinutes == 0 ? 'Cancel Timer' : 'Set',
                                style: AppTypographyMusium.labelLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int minutes) {
    if (minutes == 0) return '00:00';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }
}

/// Show sleep timer modal
Future<int?> showSleepTimerModal(BuildContext context) {
  return showModalBottomSheet<int?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => const SleepTimerModalMusium(),
    ),
  );
}
