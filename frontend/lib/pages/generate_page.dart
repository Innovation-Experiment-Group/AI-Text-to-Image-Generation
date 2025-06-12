import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/image_service.dart';
import '../services/style_service.dart';
import '../utils/constants.dart';
import '../widgets/image_prompt_input.dart';
import '../models/style.dart';
import '../models/image_item.dart';
import 'image_detail_page.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final _promptController = TextEditingController();
  final _negativeController = TextEditingController();
  bool _isPublic = true;
  bool _loading = false;
  List<Style> _styles = [];
  String? _selectedStyle;
  ImageItem? _generatedImage;

  @override
  void initState() {
    super.initState();
    _loadStyles();
  }

  Future<void> _loadStyles() async {
    final styles = await StyleService.getStyles();
    setState(() {
      _styles = styles;
      _selectedStyle = styles.isNotEmpty ? styles.first.name : null;
    });
  }

  Future<void> _generate() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入图像描述')));
      return;
    }

    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenKey);
      if (token == null) throw Exception('未登录');

      final image = await ImageService.generateImage(
        token: token,
        prompt: prompt,
        negativePrompt: _negativeController.text,
        style: _selectedStyle,
        isPublic: _isPublic,
      );
      setState(() => _generatedImage = image);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('生成失败：$e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildStyleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStyle,
      items:
          _styles
              .map((s) => DropdownMenuItem(value: s.name, child: Text(s.name)))
              .toList(),
      onChanged: (value) => setState(() => _selectedStyle = value),
      decoration: const InputDecoration(labelText: '选择风格'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('生成图片')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ImagePromptInput(
              promptController: _promptController,
              negativeController: _negativeController,
              isPublic: _isPublic,
              onTogglePublic: (val) => setState(() => _isPublic = val),
            ),
            const SizedBox(height: 12),
            _buildStyleDropdown(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _generate,
              child:
                  _loading
                      ? const CircularProgressIndicator()
                      : const Text('生成'),
            ),
            const SizedBox(height: 20),
            if (_generatedImage != null)
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ImageDetailPage(
                              imageId: _generatedImage!.imageId,
                            ),
                      ),
                    ),
                child: Image.network(_generatedImage!.imageUrl),
              ),
          ],
        ),
      ),
    );
  }
}
