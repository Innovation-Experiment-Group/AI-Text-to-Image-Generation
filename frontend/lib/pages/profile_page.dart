import 'package:flutter/material.dart';
// 保留您原来的 imports
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
  // 您原有的状态变量和数据加载逻辑保持不变
  User? _user;
  List<ImageItem> _userImages = [];
  bool _loadingUser = true;
  bool _loadingImages = true;
  int _sidebarSelectedIndex = 6; // 假设“个人中心”在侧边栏是第7项(索引6)

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 同时加载用户信息和图片
    await Future.wait([_loadUser(), _loadUserImages()]);
  }

  Future<void> _loadUser() async {
    if (!mounted) return;
    setState(() => _loadingUser = true);
    try {
      final res = await AuthService.getProfile();
      if (!mounted) return;
      setState(() => _user = User.fromJson(res['data']));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('加载用户信息失败')));
    } finally {
      if (mounted) setState(() => _loadingUser = false);
    }
  }

  Future<void> _loadUserImages() async {
    if (!mounted) return;
    setState(() => _loadingImages = true);
    try {
      final images = await ImageService.fetchUserImages();
      if (!mounted) return;
      setState(() => _userImages = images);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('加载用户图片失败')));
    } finally {
      if (mounted) setState(() => _loadingImages = false);
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

  // --- UI 构建部分 ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), // 统一的背景色
      body: Row(
        children: [
          // 左侧侧边栏 (与首页风格一致)
          _buildSidebar(),
          // 右侧主内容区
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  // 构建与首页风格一致的侧边栏
  // 注意：您需要将这个侧边栏组件提取成一个公共的 Widget，
  // 以便在 HomePage 和 ProfilePage 中复用。这里为了演示，暂时写在一起。
  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Row(
              children: [
                Icon(Icons.widgets_outlined, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '导航菜单',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              '功能入口',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          _buildSidebarItem('首页', Icons.home_outlined, 0),
          _buildSidebarItem('云生图', Icons.cloud_outlined, 1),
          _buildSidebarItem('风格选择', Icons.style_outlined, 2),
          _buildSidebarItem('热门风格', Icons.whatshot_outlined, 3),
          _buildSidebarItem('自定义风格', Icons.edit_outlined, 4),
          _buildSidebarItem('更多风格', Icons.more_horiz_outlined, 5),
          const Divider(height: 30, indent: 20, endIndent: 20),
          _buildSidebarItem('个人中心', Icons.person_outline, 6), // 新增个人中心项
          const Spacer(),
          // ... 底部登录按钮和用户状态可以放在这里 ...
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String title, IconData icon, int index) {
    final isSelected = _sidebarSelectedIndex == index;
    return GestureDetector(
      onTap: () {
        // TODO: 处理导航逻辑，例如使用 Navigator.pushReplacementNamed
        // setState(() => _sidebarSelectedIndex = index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建主内容区
  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(32.0),
        children: [
          // 大标题，替换 AppBar
          const Text(
            '个人中心',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 24),

          // 用户信息卡片
          _buildUserInfoCard(),

          const SizedBox(height: 24),

          // 我的图片卡片
          _buildUserImagesCard(),
        ],
      ),
    );
  }

  // 构建用户信息卡片
  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child:
          _loadingUser
              ? const Center(child: CircularProgressIndicator())
              : _user == null
              ? const Center(child: Text('未获取到用户信息'))
              : Column(
                children: [
                  GestureDetector(
                    onTap:
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('头像修改功能未实现')),
                        ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _user!.avatarUrl != null
                              ? NetworkImage(_user!.avatarUrl!)
                              : null,
                      child:
                          _user!.avatarUrl == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.nickname ?? '匿名用户',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user!.bio ?? '这个人很懒，什么也没写。',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
    );
  }

  // 构建用户图片卡片
  Widget _buildUserImagesCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '我的图片',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _loadingImages
              ? const Center(child: CircularProgressIndicator())
              : _userImages.isEmpty
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Text('你还没有生成过任何图片'),
                ),
              )
              : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 在更宽的屏幕上可以显示更多列
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final img = _userImages[index];
                  return GestureDetector(
                    onTap: () => _onImageTap(img),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        img.thumbnailUrl,
                        fit: BoxFit.cover,
                        // 添加加载和错误占位符，提升体验
                        loadingBuilder: (context, child, progress) {
                          return progress == null
                              ? child
                              : const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                ),
                              );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
}
