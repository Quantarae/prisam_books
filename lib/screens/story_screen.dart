import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/story_page_model.dart';
import '../widgets/rive_animation_placeholder.dart';

class StoryScreen extends StatefulWidget {
  final String storyAssetPath;
  final String? bookTitle;
  const StoryScreen({
    super.key,
    this.storyAssetPath = 'assets/story.json',
    this.bookTitle,
  });

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _narrationPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();

  List<StoryPageModel> pages = [];
  int currentPage = 0;
  bool narrationEnabled = true;
  bool _isPlaying = false;
  double _pageOffset = 0.0;

  StreamSubscription<dynamic>? _completeSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStory();

    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          _pageOffset = _pageController.page ?? 0.0;
        });
      }
    });

    _completeSub = _narrationPlayer.onPlayerComplete.listen((_) {
      setState(() => _isPlaying = false);
    });

    _flutterTts.setStartHandler(() {
      setState(() => _isPlaying = true);
    });
    _flutterTts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Stop narration when app is backgrounded or screen locked
      _narrationPlayer.stop();
      _flutterTts.stop();
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _completeSub?.cancel();
    _pageController.dispose();
    _sfxPlayer.dispose();
    _narrationPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadStory() async {
    try {
      final raw = await rootBundle.loadString(widget.storyAssetPath);
      final List<dynamic> list = json.decode(raw);
      setState(() {
        pages = list.map((e) => StoryPageModel.fromJson(e)).toList();
      });
      if (pages.isNotEmpty && narrationEnabled) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _playNarration(0));
      }
    } catch (e) {
      debugPrint('Error loading story: $e');
    }
  }

  Future<void> _playNarration(int index) async {
    if (index < 0 || index >= pages.length || !narrationEnabled) return;
    final page = pages[index];
    try {
      await _narrationPlayer.stop();
      await _flutterTts.stop();

      String base = _getBasePath(widget.storyAssetPath);
      if (page.audio != null && page.audio!.isNotEmpty) {
        var assetPath = '${base}audio/${page.audio}';
        if (assetPath.startsWith('assets/')) {
          assetPath = assetPath.substring('assets/'.length);
        }
        await _narrationPlayer.play(AssetSource(assetPath));
      } else {
        await _flutterTts.setLanguage('en-US');
        await _flutterTts.speak(page.text);
      }
    } catch (e) {
      debugPrint('Error playing narration: $e');
    }
  }

  String _getBasePath(String path) {
    final idx = path.lastIndexOf('/');
    if (idx == -1) return '';
    return path.substring(0, idx + 1);
  }

  void _onPageChanged(int idx) {
    setState(() => currentPage = idx);
    _playNarration(idx);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        final bool? shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Story?'),
            content: const Text('Do you want to go back to the library?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          await _narrationPlayer.stop();
          await _flutterTts.stop();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text(
            widget.bookTitle ?? 'Story',
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(
                !narrationEnabled
                    ? Icons.volume_off
                    : (_isPlaying ? Icons.stop : Icons.play_arrow),
                color: Colors.indigo,
              ),
              onPressed: () {
                setState(() {
                  narrationEnabled = !narrationEnabled;
                });
                if (narrationEnabled) {
                  _playNarration(currentPage);
                } else {
                  _narrationPlayer.stop();
                  _flutterTts.stop();
                }
              },
            )
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/background_paper.png',
                  fit: BoxFit.cover),
            ),
            pages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      double difference = index - _pageOffset;

                      // Simple 3D flip effect
                      double rotation = 0.0;
                      double translation = 0.0;
                      double opacity = 1.0;

                      if (difference < 0) {
                        // Page is moving to the left
                        rotation = difference * (math.pi / 2);
                        translation =
                            difference * MediaQuery.of(context).size.width;
                        opacity = (1 + difference).clamp(0.0, 1.0);
                      }

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // perspective
                          ..translate(translation)
                          ..rotateY(rotation),
                        alignment: Alignment.centerLeft,
                        child: Opacity(
                          opacity: opacity,
                          child: _StoryPage(
                            page: pages[index],
                            basePath: _getBasePath(widget.storyAssetPath),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class _StoryPage extends StatelessWidget {
  final StoryPageModel page;
  final String basePath;

  const _StoryPage({required this.page, required this.basePath});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: _buildMedia(),
            ),
            const SizedBox(height: 24),
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (page.title.isNotEmpty)
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      if (page.title.isNotEmpty) const SizedBox(height: 12),
                      Text(
                        page.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          color: Colors.black87,
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
    );
  }

  Widget _buildMedia() {
    if (page.lottie != null && page.lottie!.isNotEmpty) {
      return Lottie.asset('${basePath}lottie/${page.lottie}',
          fit: BoxFit.contain);
    }
    if (page.rive != null && page.rive!.isNotEmpty) {
      return const RiveAnimationPlaceholder();
    }
    if (page.image != null && page.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child:
            Image.asset('${basePath}images/${page.image}', fit: BoxFit.contain),
      );
    }
    return const Icon(Icons.menu_book, size: 120, color: Colors.grey);
  }
}
