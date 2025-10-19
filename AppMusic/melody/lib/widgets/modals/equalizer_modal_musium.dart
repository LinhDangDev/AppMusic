import 'package:flutter/material.dart';
import 'package:melody/constants/app_colors_musium.dart';
import 'package:melody/constants/app_typography_musium.dart';

/// Equalizer Modal - Advanced audio settings
class EqualizerModalMusium extends StatefulWidget {
  const EqualizerModalMusium({Key? key}) : super(key: key);

  @override
  State<EqualizerModalMusium> createState() => _EqualizerModalMusiumState();
}

class _EqualizerModalMusiumState extends State<EqualizerModalMusium> {
  late Map<String, double> bandValues;
  String selectedPreset = 'Normal';

  final List<String> presets = [
    'Normal',
    'Bass',
    'Treble',
    'Vocal',
    'Classical',
    'Pop',
    'Jazz',
    'Custom',
  ];

  final List<String> bands = ['60Hz', '250Hz', '1kHz', '4kHz', '16kHz'];

  @override
  void initState() {
    super.initState();
    bandValues = {
      '60Hz': 0.0,
      '250Hz': 0.0,
      '1kHz': 0.0,
      '4kHz': 0.0,
      '16kHz': 0.0,
    };
  }

  void _setPreset(String preset) {
    setState(() {
      selectedPreset = preset;
      switch (preset) {
        case 'Bass':
          bandValues = {
            '60Hz': 0.5,
            '250Hz': 0.3,
            '1kHz': 0.0,
            '4kHz': -0.2,
            '16kHz': -0.3,
          };
          break;
        case 'Treble':
          bandValues = {
            '60Hz': -0.3,
            '250Hz': -0.2,
            '1kHz': 0.0,
            '4kHz': 0.4,
            '16kHz': 0.5,
          };
          break;
        case 'Vocal':
          bandValues = {
            '60Hz': -0.2,
            '250Hz': 0.2,
            '1kHz': 0.4,
            '4kHz': 0.3,
            '16kHz': 0.1,
          };
          break;
        case 'Classical':
          bandValues = {
            '60Hz': 0.2,
            '250Hz': 0.1,
            '1kHz': -0.1,
            '4kHz': 0.2,
            '16kHz': 0.4,
          };
          break;
        case 'Pop':
          bandValues = {
            '60Hz': 0.3,
            '250Hz': 0.2,
            '1kHz': 0.0,
            '4kHz': 0.1,
            '16kHz': 0.2,
          };
          break;
        case 'Jazz':
          bandValues = {
            '60Hz': 0.2,
            '250Hz': 0.3,
            '1kHz': 0.1,
            '4kHz': -0.1,
            '16kHz': 0.3,
          };
          break;
        default:
          bandValues = {
            '60Hz': 0.0,
            '250Hz': 0.0,
            '1kHz': 0.0,
            '4kHz': 0.0,
            '16kHz': 0.0,
          };
      }
    });
  }

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
                  'Equalizer',
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
                // Presets section
                Text(
                  'Presets',
                  style: AppTypographyMusium.heading5.copyWith(
                    color: AppColorMusium.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Preset buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets.map((preset) {
                    final isSelected = selectedPreset == preset;
                    return GestureDetector(
                      onTap: () => _setPreset(preset),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
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
                        child: Text(
                          preset,
                          style: AppTypographyMusium.bodySmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColorMusium.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // Bands section
                Text(
                  'Frequency Bands',
                  style: AppTypographyMusium.heading5.copyWith(
                    color: AppColorMusium.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Band sliders
                ..._buildBandSliders(),

                const SizedBox(height: 28),

                // Reset button
                Container(
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
                      onTap: () => _setPreset('Normal'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: AppColorMusium.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reset to Normal',
                            style: AppTypographyMusium.labelLarge.copyWith(
                              color: AppColorMusium.textSecondary,
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
        ],
      ),
    );
  }

  List<Widget> _buildBandSliders() {
    return bands.map((band) {
      final value = bandValues[band] ?? 0.0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  band,
                  style: AppTypographyMusium.bodySmall.copyWith(
                    color: AppColorMusium.textPrimary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppColorMusium.darkSurfaceLight,
                  ),
                  child: Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: AppTypographyMusium.bodySmall.copyWith(
                      color: AppColorMusium.accentTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColorMusium.accentTeal,
                inactiveTrackColor:
                    AppColorMusium.textTertiary.withValues(alpha: 0.2),
                thumbColor: AppColorMusium.accentTeal,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6,
                ),
                trackHeight: 6,
              ),
              child: Slider(
                value: value,
                min: -1.0,
                max: 1.0,
                onChanged: (newValue) {
                  setState(() {
                    bandValues[band] = newValue;
                    selectedPreset = 'Custom';
                  });
                },
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

/// Show equalizer modal
Future<void> showEqualizerModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => const EqualizerModalMusium(),
    ),
  );
}
