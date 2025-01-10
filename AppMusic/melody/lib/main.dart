import 'package:flutter/material.dart';
import 'package:melody/screens/home_screen.dart';
import 'package:audio_service/audio_service.dart';
import 'package:melody/services/audio_handler.dart';
import 'package:get/get.dart';
import 'package:melody/provider/music_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  
  Get.put(MusicController());
  
  runApp(const MyApp());
}

Future<void> initializeService() async {
  await AudioService.init(
    builder: () => MyAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.myapp.audio',
      androidNotificationChannelName: 'Audio Service',
      androidNotificationOngoing: true,
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
