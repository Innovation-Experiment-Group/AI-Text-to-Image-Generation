import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 用于追踪侧边栏的选中项，默认选中 "风格选择" (index 2)
  int _selectedIndex = 2;

  // 注意：原有的 initState 中的数据获取逻辑已移除，
  // 因为新界面不需要展示图片画廊。
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 这里不再需要 Provider.of<ImageProviderModel>(context)
    // 因为 UI 已经完全改变

    return Scaffold(
      // 设置整体背景色以匹配图片
      backgroundColor: const Color(0xFFF7F8FA),
      body: Row(
        children: [
          // 左侧侧边栏
          _buildSidebar(),
          // 右侧主内容区，用 Expanded 占据剩余空间
          Expanded(
            child: Column(
              children: [
                // 主要内容区域，用 Expanded 占据垂直方向的剩余空间
                Expanded(child: _buildMainContent()),
                // 底部输入框
                _buildBottomInputField(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 辅助方法：构建左侧侧边栏
  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部 Logo/标题 (根据图片做的示意)
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
          // 功能入口标题
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              '功能入口',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          // 菜单项
          _buildSidebarItem('首页', Icons.home_outlined, 0),
          _buildSidebarItem('云生图', Icons.cloud_outlined, 1),
          _buildSidebarItem('风格选择', Icons.style, 2), // 使用实心图标表示选中
          _buildSidebarItem('热门风格', Icons.whatshot_outlined, 3),
          _buildSidebarItem('自定义风格', Icons.edit_outlined, 4),
          _buildSidebarItem('更多风格', Icons.more_horiz_outlined, 5),
          const Spacer(), // 占据所有可用空间，将底部内容推到底部
          // 登录按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 实现登录逻辑
                },
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
          ),
          const SizedBox(height: 20),
          // 底部用户状态
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFE0E0E0),
                  // 图片中是用户头像，这里用占位符
                  child: Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 10),
                Text('未登录', style: TextStyle(color: Colors.black54)),
                Spacer(),
                Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 辅助方法：构建单个侧边栏菜单项
  Widget _buildSidebarItem(String title, IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        // TODO: 在这里处理导航逻辑
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

  // 辅助方法：构建右侧主内容区
  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // "访问官网" 按钮，使用 Positioned 定位在右上角
          Positioned(
            top: 0,
            right: 0,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: 实现访问官网逻辑
              },
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
          // 中心内容
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 头像
              const CircleAvatar(
                radius: 40,
                // 您可以替换为自己的图片资源
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=3',
                ),
              ),
              const SizedBox(height: 24),
              // 大标题
              const Text(
                'AI云生图风格选择',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              // 副标题
              const Text(
                '多种风格任您选，开启创意无限的AI云生图之旅!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              // 示例提示词按钮
              _buildPromptButton('示例提示词'),
              _buildPromptButton('示例提示词'),
              _buildPromptButton('AI示例提示词'),
              _buildPromptButton('风格多样，满足创意需求'),
              const SizedBox(height: 20),
              // 换一批按钮
              TextButton(
                onPressed: () {
                  // TODO: 实现换一批逻辑，例如重新加载提示词
                },
                child: const Text(
                  '换一批',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 辅助方法：构建示例提示词按钮
  Widget _buildPromptButton(String text) {
    return Container(
      width: 300, // 给定一个固定宽度，让按钮看起来更整齐
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: OutlinedButton(
        onPressed: () {
          // TODO: 实现点击提示词的逻辑
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

  // 辅助方法：构建底部输入框
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
              onPressed: () {
                // TODO: 清除输入内容
              },
            ),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '登录后，可向我发送问题',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.blue),
              onPressed: () {
                // TODO: 发送消息
              },
            ),
          ],
        ),
      ),
    );
  }
}
