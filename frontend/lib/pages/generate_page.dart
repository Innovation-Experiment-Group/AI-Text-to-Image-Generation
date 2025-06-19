// lib/pages/generate_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/image_item.dart';
import '../providers/image_provider.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({Key? key}) : super(key: key);

  @override
  _GeneratePageState createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _negativePromptController =
      TextEditingController();

  // 保持状态，而不是用控制器
  String? _selectedStyle;

  bool _isGenerating = false;
  ImageItem? _generatedImage;

  Future<void> _generateImage() async {
    // ScaffoldMessenger 现在需要从 MainLayout 的 context 获取
    // 我们可以在调用时通过 context.findRootAncestorStateOfType<ScaffoldMessengerState>()
    // 或者直接使用 Builder widget，但为了简单起见，我们暂时依赖于 MainLayout 的 context
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final imageProvider = context.read<ImageProviderModel>();

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('请输入生成提示词')));
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedImage = null;
    });

    try {
      final newImage = await imageProvider.generateImage(
        prompt: prompt,
        negativePrompt:
            _negativePromptController.text.trim().isEmpty
                ? null
                : _negativePromptController.text.trim(),
        style: _selectedStyle, // 使用 _selectedStyle
        isPublic: true,
        width: 512,
        height: 512,
        samplingSteps: 30,
      );
      setState(() {
        _generatedImage = newImage;
      });
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('🎉 生成成功！')));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('生成失败: $e')));
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _negativePromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // REMOVED: Scaffold, AppBar
    // 我们使用 ListView 来确保内容过多时可以滚动
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
      children: [
        // 页面标题和描述
        const Text(
          '开始你的创作',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '输入你的想法，选择喜欢的风格，让AI为你绘制独一无二的艺术作品。',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 40),

        // 输入表单区域
        _buildTextField(
          controller: _promptController,
          label: '正向提示词 (Prompt)',
          hint: '例如：一只穿着宇航服的猫在月球上，超写实风格',
          maxLines: 5,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _negativePromptController,
          label: '负向提示词 (可选)',
          hint: '例如：模糊、低质量、丑陋',
          maxLines: 2,
        ),
        const SizedBox(height: 20),

        // 风格选择 - 改用更美观的下拉菜单
        _buildStyleSelector(),
        const SizedBox(height: 32),

        // 生成按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon:
                _isGenerating
                    ? Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? '正在生成中...' : '立即生成'),
            onPressed: _isGenerating ? null : _generateImage,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),

        // 结果展示区
        if (_generatedImage != null) _buildResultSection(_generatedImage!),
      ],
    );
  }

  // 封装一个美化的文本输入框构建方法
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  // 构建风格选择器
  Widget _buildStyleSelector() {
    // 定义一些预设风格
    const styles = ['无风格', '动漫', '水彩', '油画', '赛博朋克', '黏土动画'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '画面风格 (可选)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedStyle,
          hint: const Text('选择一个风格'),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items:
              styles.map((String style) {
                return DropdownMenuItem<String>(
                  value: style == '无风格' ? null : style,
                  child: Text(style),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedStyle = newValue;
            });
          },
        ),
      ],
    );
  }

  // 构建结果展示区域
  Widget _buildResultSection(ImageItem image) {
    return Column(
      children: [
        const Text(
          '生成结果',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            image.imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return AspectRatio(
                aspectRatio: 1,
                child: Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('图片加载失败'),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
