// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'game/flow_state.dart';
import 'utils/audio_manager.dart';
import 'utils/preferences.dart';
import 'screens/home_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF06060C),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await Preferences.instance.init();
  await AudioManager.instance.init();
  runApp(const VoltFlowApp());
}

class VoltFlowApp extends StatelessWidget {
  const VoltFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FlowState(),
      child: MaterialApp(
        title: 'VoltFlow',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF06060C),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00E5FF),
            surface: Color(0xFF101019),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
