import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/main_shell.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SortifyApp());
}

class SortifyApp extends StatefulWidget {
  const SortifyApp({super.key});

  @override
  State<SortifyApp> createState() => _SortifyAppState();
}

class _SortifyAppState extends State<SortifyApp> with WidgetsBindingObserver {
  final GameProvider _game = GameProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game.init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause music when the app goes to background.
    if (state == AppLifecycleState.resumed) {
      _game.sound.resumeBackgroundMusic();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _game.sound.pauseBackgroundMusic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameProvider>.value(
      value: _game,
      child: MaterialApp(
        title: 'Sortify - 3D Liquid Sorting',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainShell(),
      ),
    );
  }
}
