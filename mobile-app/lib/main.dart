import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/player_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
  );
  runApp(const YTMRemoteApp());
}

class YTMRemoteApp extends StatelessWidget {
  const YTMRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Now Playing Ctrl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF030303),
        primaryColor: const Color(0xFFFF0000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF0000),
          surface: Color(0xFF1C1C1E),
        ),
        useMaterial3: true,
      ),
      home: const PlayerScreen(),
    );
  }
}
