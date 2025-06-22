// lib/pages/home_page.dart (极简版，只做导航)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onNavigate(int index, String routeName) {
    setState(() => _selectedIndex = index);
    if (routeName == '/home') {
      // 已经在首页，什么都不做或给个提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("已在首页")));
    } else {
      Navigator.pushNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(child: _buildMainContent(context)),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    return Container(
      width: 240,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              children: [
                Icon(Icons.palette_outlined, color: Colors.blue, size: 28),
                SizedBox(width: 8),
                Text(
                  'AI 画廊',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSidebarItem('首页', Icons.home_outlined, 0, '/home'),
          _buildSidebarItem(
            '去创作',
            Icons.add_photo_alternate_outlined,
            1,
            '/generate',
          ),
          const Divider(indent: 20, endIndent: 20, height: 40),
          _buildSidebarItem('个人中心', Icons.person_outline, 2, '/profile'),
          const Spacer(),
          userProvider.isLoggedIn
              ? _buildUserInfoSection(context, userProvider)
              : _buildLoginButton(context),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    String title,
    IconData icon,
    int index,
    String routeName,
  ) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavigate(index, routeName),
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

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/login'),
        child: const Text('登录 / 注册'),
      ),
    );
  }

  Widget _buildUserInfoSection(
    BuildContext context,
    UserProvider userProvider,
  ) {
    final user = userProvider.user;
    final avatarUrl = user?.avatarUrl;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 10, 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage:
                (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : null,
            child:
                (avatarUrl == null || avatarUrl.isEmpty)
                    ? const Icon(Icons.person, size: 20)
                    : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              user?.nickname ?? user?.username ?? '游客',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                context.read<UserProvider>().logout();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            icon: const Icon(Icons.more_horiz, color: Colors.grey),
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('注销'),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "欢迎来到 AI 画廊",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "请从左侧菜单选择功能",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
