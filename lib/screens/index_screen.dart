import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'story_screen.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  List<Map<String, dynamic>> books = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final raw = await rootBundle.loadString('assets/books.json');
      final List<dynamic> list = json.decode(raw);
      setState(() {
        books = List<Map<String, dynamic>>.from(list);
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading books: $e');
      setState(() {
        books = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.white.withOpacity(0.2)),
          ),
        ),
        title: Text(
          'Magic Library',
          style: TextStyle(
            color: Colors.indigo[900],
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_paper.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.indigo.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 24,
                            childAspectRatio: 0.65,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final book = books[index];
                              return _BookCard(
                                title: book['title'] ?? 'Story',
                                thumbnail: book['thumbnail'],
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => StoryScreen(
                                        storyAssetPath: book['story'],
                                        bookTitle: book['title'],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: books.length,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 40)),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final String title;
  final String thumbnail;
  final VoidCallback onTap;

  const _BookCard({
    required this.title,
    required this.thumbnail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.indigo[50],
                          child: const Icon(Icons.menu_book, size: 48, color: Colors.indigo),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'Read Now',
              style: TextStyle(
                fontSize: 12,
                color: Colors.indigo,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

