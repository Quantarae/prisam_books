import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/index_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Startup asset diagnostic: try to load a known story.json and print
  // whether AssetManifest contains it. This helps debug cases where the
  // asset is present in the project but fails to load at runtime.
  const testPath = 'assets/stories/best_day_out/story.json';
  try {
    final raw = await rootBundle.loadString(testPath);
    debugPrint(
        '[StartupAssetCheck] Successfully loaded $testPath; length=${raw.length}');
  } catch (e, st) {
    debugPrint('[StartupAssetCheck] Failed loading $testPath: $e');
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      final contains = manifest.contains(testPath);
      debugPrint(
          '[StartupAssetCheck] AssetManifest contains $testPath: $contains');
    } catch (e2, st2) {
      debugPrint('[StartupAssetCheck] Failed reading AssetManifest.json: $e2');
    }
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const StoryBooksApp());
}

class StoryBooksApp extends StatelessWidget {
  const StoryBooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryBooks Prototype',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const IndexScreen(),
    );
  }
}
