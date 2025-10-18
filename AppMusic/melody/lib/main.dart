import 'package:flutter/material.dart';
import 'package:melody/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:melody/provider/audio_provider.dart';
import 'package:melody/provider/music_controller.dart';

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
    return GetMaterialApp(
      title: 'Music App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.black,
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
          modalBackgroundColor: Colors.transparent,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
