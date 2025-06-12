import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/image_service.dart';
import '../models/user.dart';
import '../models/image_item.dart';
import 'image_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  List<ImageItem> _userImages = [];
  bool _loadingUser = true;
  bool _loadingImages = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadUserImages();
  }

  Future<void> _loadUser() async {
    setState(() => _loadingUser = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      // 未登录，跳转登录页或显示提示
      return;
    }
    try {
      final user = await AuthService.getProfile(token);
      setState(() => _user = user);
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('加载用户信息失败')));
    } finally {
      setState(() => _loadingUser = false);
    }
  }

  Future<void> _loadUserImages() async {
    setState(() => _loadingImages = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final images = await ImageService.getUserImages(token);
      setState(() => _userImages = images);
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('加载用户图片失败')));
    } finally {
      setState(() => _loadingImages = false);
    }
  }

  void _onImageTap(ImageItem image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageDetailPage(imageId: image.imageId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_loadUser(), _loadUserImages()]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loadingUser)
              const Center(child: CircularProgressIndicator())
            else if (_user == null)
              const Center(child: Text('未获取到用户信息'))
            else ...[
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: 实现头像修改功能
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('头像修改功能未实现')));
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_user!.avatarUrl ?? ''),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _user!.nickname ?? '匿名用户',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  _user!.bio ?? '这个人很懒，什么也没写。',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const Divider(height: 32),
            ],
            const Text(
              '我的图片',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_loadingImages)
              const Center(child: CircularProgressIndicator())
            else if (_userImages.isEmpty)
              const Center(child: Text('还没有上传过图片'))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final img = _userImages[index];
                  return GestureDetector(
                    onTap: () => _onImageTap(img),
                    child: Image.network(img.imageUrl, fit: BoxFit.cover),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
