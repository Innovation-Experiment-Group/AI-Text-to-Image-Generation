// lib/pages/profile_page.dart (智能URL处理版)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/image_provider.dart';
import 'image_detail_page.dart';
import '../utils/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- 新增：智能URL构建辅助函数 ---
  String _buildFullUrl(String relativeUrl) {
    if (relativeUrl.isEmpty) {
      return ''; // 如果路径为空，返回空，让 errorBuilder 处理
    }
    if (relativeUrl.startsWith('http')) {
      return relativeUrl; // 如果已经是完整URL，直接返回
    }
    // 否则，拼接基础URL
    final baseUrl = Constants.baseUrl.replaceAll('/api', '');
    return '$baseUrl$relativeUrl';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ImageProviderModel>().fetchUserImages();
    });
  }

  Future<void> _refreshData() async {
    await context.read<ImageProviderModel>().fetchUserImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: const EdgeInsets.all(32.0),
          children: [
            _buildUserInfoCard(),
            const SizedBox(height: 24),
            _buildUserImagesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final fullAvatarUrl = _buildFullUrl(user?.avatarUrl ?? '');

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                fullAvatarUrl.isNotEmpty ? NetworkImage(fullAvatarUrl) : null,
            child:
                fullAvatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
          ),
          const SizedBox(height: 16),
          Text(
            user?.nickname ?? user?.username ?? '未知用户',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            user?.bio ?? '这个人很懒，什么也没写。',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserImagesCard() {
    final imageProvider = context.watch<ImageProviderModel>();
    final images = imageProvider.images;
    final isLoading = imageProvider.isLoading;

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
          if (isLoading && images.isEmpty)
            const Center(child: CircularProgressIndicator()),
          if (!isLoading && images.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Text('你还没有生成过任何图片'),
              ),
            ),
          if (images.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final img = images[index];
                final fullThumbnailUrl = _buildFullUrl(img.thumbnailUrl);

                return GestureDetector(
                  onTap: () {
                    if (img.imageId.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ImageDetailPage(imageId: img.imageId),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("图片ID无效，无法查看详情")),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child:
                        fullThumbnailUrl.isEmpty
                            ? Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.error, color: Colors.red),
                            )
                            : Image.network(
                              fullThumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
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
