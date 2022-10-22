import 'package:flutter/material.dart';
import 'package:maps_markers/cons.dart';
import 'package:maps_markers/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) => MaterialApp(
          title: 'Maps Multiple Marker',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          darkTheme: darkTheme(),
          theme: lightTheme(),
          home: const MapsScreen()),
    );
  }
}
