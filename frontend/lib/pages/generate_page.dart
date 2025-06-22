// lib/pages/generate_page.dart (智能URL处理版)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/image_item.dart';
import '../providers/image_provider.dart';
import '../utils/constants.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({Key? key}) : super(key: key);

  @override
  _GeneratePageState createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _negativePromptController =
      TextEditingController();

  String? _selectedStyle;
  bool _isGenerating = false;
  ImageItem? _generatedImage;

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

  Future<void> _generateImage() async {
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
        style: _selectedStyle,
        isPublic: true,
      );
      setState(() {
        _generatedImage = newImage;
      });
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('🎉 生成成功！')));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('生成失败: $e')));
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('开始你的创作'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        children: [
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
          _buildStyleSelector(),
          const SizedBox(height: 32),
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
          if (_generatedImage != null) _buildResultSection(_generatedImage!),
        ],
      ),
    );
  }

  Widget _buildResultSection(ImageItem image) {
    final fullImageUrl = _buildFullUrl(image.imageUrl);

    return Column(
      children: [
        const Text(
          '生成结果',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child:
              fullImageUrl.isEmpty
                  ? Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.red),
                    ),
                  )
                  : Image.network(
                    fullImageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

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

  Widget _buildStyleSelector() {
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
              styles
                  .map(
                    (String style) => DropdownMenuItem<String>(
                      value: style == '无风格' ? null : style,
                      child: Text(style),
                    ),
                  )
                  .toList(),
          onChanged:
              (String? newValue) => setState(() => _selectedStyle = newValue),
        ),
      ],
    );
  }
}
