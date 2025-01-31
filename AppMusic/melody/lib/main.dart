import 'package:flutter/material.dart';
import 'package:melody/screens/home_screen.dart';
import 'package:audio_service/audio_service.dart';
import 'package:melody/services/audio_handler.dart';
import 'package:get/get.dart';
import 'package:melody/provider/music_controller.dart';
import 'package:provider/provider.dart';
import 'package:melody/provider/audio_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final musicController = Get.put(MusicController());
  final audioProvider = AudioProvider();
  await audioProvider.initAudioHandler();
  
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
