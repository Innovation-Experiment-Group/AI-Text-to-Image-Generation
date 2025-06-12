import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/image_item.dart';
import '../services/image_service.dart';
import '../utils/constants.dart';
import '../widgets/image_card.dart';
import '../widgets/loading_spinner.dart';
import 'image_detail_page.dart';
import 'profile_page.dart';
import 'generate_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ImageItem> _images = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchImages({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final page = refresh ? 1 : _page;
      final images = await ImageService.getGallery(page: page);

      setState(() {
        if (refresh) {
          _images = images;
          _page = 2;
        } else {
          _images.addAll(images);
          _page++;
        }
        _hasMore = images.length >= 20;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载失败：$e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (_hasMore && !_isLoading) {
        _fetchImages();
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    Navigator.pushReplacementNamed(context, '/');
  }

  void _goToGenerate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GeneratePage()),
    );
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('画廊'),
        actions: [
          IconButton(onPressed: _goToProfile, icon: const Icon(Icons.person)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchImages(refresh: true),
        child:
            _images.isEmpty && _isLoading
                ? const LoadingSpinner()
                : ListView.builder(
                  controller: _scrollController,
                  itemCount: _images.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _images.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final image = _images[index];
                    return ImageCard(
                      imageUrl: image.imageUrl,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ImageDetailPage(imageId: image.imageId),
                          ),
                        );
                      },
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToGenerate,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
