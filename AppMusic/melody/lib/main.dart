import 'package:flutter/material.dart';
import 'package:melody/widgets/navigation/bottom_nav_bar_musium.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:melody/provider/audio_provider.dart';
import 'package:melody/provider/music_controller.dart';
import 'package:melody/constants/app_typography_musium.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioProvider = AudioProvider();
  await audioProvider.initAudioHandler();

  // Register MusicController with GetX
  Get.put(MusicController());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: audioProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create the Musium dark theme
    final darkTheme = AppTypographyMusium.createDarkTheme();

    return GetMaterialApp(
      title: 'Musium',
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // Always use dark theme
      home: const MainAppContainer(), // Use MainAppContainer for bottom nav
      routes: {
        '/main': (context) => const MainAppContainer(),
      },
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
