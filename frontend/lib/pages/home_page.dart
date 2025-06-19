import 'package:flutter/material.dart';
import 'dart:async';
// 1. 引入 url_launcher 包，用于打开网页
import 'package:url_launcher/url_launcher.dart';

// 辅助类，用于模拟用户数据
class User {
  final String nickname;
  final String avatarUrl;
  User({required this.nickname, required this.avatarUrl});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;
  final TextEditingController _textController = TextEditingController();
  bool _isSending = false;

  // --- 新增状态来管理登录和提示词 ---
  bool _isLoggedIn = false;
  User? _currentUser;
  int _currentPromptBatchIndex = 0;

  // 模拟的多组提示词
  final List<List<String>> _promptBatches = [
    ['一只穿着宇航服的猫在月球上行走', '赛博朋克风格的东京雨夜街道', '梵高星空画风的埃菲尔铁塔', '水彩画：一座宁静的湖边小屋'],
    ['中世纪骑士与巨龙的史诗对决', '一个发光的魔法森林，有精灵居住', '未来城市的悬浮汽车交通', '蒸汽朋克风格的机械猫头鹰'],
    ['一个孩子在星空下放飞梦想的风筝', '海底失落的亚特兰蒂斯古城', '中国水墨画：云雾缭绕的黄山', '像素艺术风格的超级马里奥世界'],
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // --- 功能实现区域 ---

  // 2. 完成【登录/注销逻辑】
  void _handleLogin() {
    setState(() {
      _isLoggedIn = true;
      _currentUser = User(
        nickname: '创意探险家',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('登录成功！'), backgroundColor: Colors.green),
    );
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _currentUser = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已注销登录。')));
  }

  // 3. 完成【发送消息逻辑】（已增强）
  Future<void> _sendMessage() async {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先登录后再发送消息！'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      _textController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('任务已提交: "$text"'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // 4. 完成【换一批逻辑】
  void _changePromptBatch() {
    setState(() {
      _currentPromptBatchIndex =
          (_currentPromptBatchIndex + 1) % _promptBatches.length;
    });
  }

  // 5. 完成【访问官网逻辑】
  Future<void> _launchOfficialSite() async {
    final Uri url = Uri.parse('https://www.flutter.dev'); // 将这里换成您的官网地址
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开官网链接'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildMainContent()),
                _buildBottomInputField(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI 构建区域（已更新） ---

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (顶部标题和功能入口部分未变)
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
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
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              '功能入口',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          _buildSidebarItem('首页', Icons.home_outlined, 0),
          _buildSidebarItem('云生图', Icons.cloud_outlined, 1),
          _buildSidebarItem('风格选择', Icons.style, 2),
          _buildSidebarItem('热门风格', Icons.whatshot_outlined, 3),
          _buildSidebarItem('自定义风格', Icons.edit_outlined, 4),
          _buildSidebarItem('更多风格', Icons.more_horiz_outlined, 5),
          const Spacer(),
          // 登录/注销 UI 动态变化
          _isLoggedIn ? _buildUserInfoSection() : _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleLogin, // 调用登录方法
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text('登录'),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 10, 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(_currentUser!.avatarUrl),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _currentUser!.nickname,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 使用 PopupMenuButton 实现更多操作，如注销
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            icon: const Icon(Icons.more_horiz, color: Colors.grey),
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
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

  Widget _buildSidebarItem(String title, IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        // 6. 完成【导航逻辑】（使用SnackBar模拟）
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已切换到: $title'),
            duration: const Duration(seconds: 1),
          ),
        );
        // 在真实应用中，这里会是 Navigator.pushNamed(context, '/$title');
      },
      child: Container(
        /* ... 样式代码未变 ... */
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

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: OutlinedButton.icon(
              onPressed: _launchOfficialSite, // 调用访问官网方法
              icon: const Icon(Icons.public, size: 16, color: Colors.black54),
              label: const Text(
                '访问官网',
                style: TextStyle(color: Colors.black54),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=3',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'AI云生图风格选择',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '多种风格任您选，开启创意无限的AI云生图之旅!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              // 动态生成提示词按钮
              ..._promptBatches[_currentPromptBatchIndex]
                  .map((prompt) => _buildPromptButton(prompt))
                  .toList(),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: _changePromptBatch, // 调用换一批方法
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('换一批', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromptButton(String text) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: OutlinedButton(
        onPressed: () {
          _textController.text = text;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black54,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildBottomInputField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 10, 40, 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => _textController.clear(),
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: _isLoggedIn ? '请输入你的创意...' : '登录后，可向我发送问题',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon:
                  _isSending
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                      : const Icon(Icons.send_rounded, color: Colors.blue),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
