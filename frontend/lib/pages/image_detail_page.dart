// lib/pages/image_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/image_item.dart';
import '../providers/comment_provider.dart';
import '../services/image_service.dart';
import '../services/comment_service.dart';
import '../widgets/comment_tile.dart';
// like_button.dart 假设它已经存在，如果不存在，需要创建或适配
// import '../widgets/like_button.dart';

class ImageDetailPage extends StatefulWidget {
  final String imageId;

  const ImageDetailPage({Key? key, required this.imageId}) : super(key: key);

  @override
  _ImageDetailPageState createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  ImageItem? _image;
  bool _isLoadingImage = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadImageDetail();
  }

  Future<void> _loadImageDetail() async {
    setState(() => _isLoadingImage = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final image = await ImageService.getImageDetail(widget.imageId);
      if (mounted) {
        setState(() => _image = image);
        await _loadComments();
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('加载图片详情失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingImage = false);
      }
    }
  }

  Future<void> _loadComments() async {
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final comments = await CommentService.getComments(widget.imageId);
      if (mounted) {
        commentProvider.setComments(comments);
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('加载评论失败: $e')));
      }
    }
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);

    if (content.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('请输入评论内容')));
      return;
    }

    try {
      final comment = await CommentService.addComment(widget.imageId, content);
      if (mounted) {
        commentProvider.addCommentSync(comment);
        _commentController.clear();
        FocusScope.of(context).unfocus();
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('评论成功')));
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('发表评论失败: $e')));
      }
    }
  }

  Future<void> _toggleLike() async {
    if (_image == null) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final liked = await ImageService.toggleLike(_image!.imageId);
      if (mounted) {
        setState(() {
          _image = _image!.copyWith(
            liked: liked,
            likes: liked ? (_image!.likes ?? 0) + 1 : (_image!.likes ?? 1) - 1,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        scrolledUnderElevation: 0, // 防止滚动时变色
        foregroundColor: Colors.black87,
        title: const Text('作品详情'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoadingImage
          ? const Center(child: CircularProgressIndicator())
          : _image == null
              ? const Center(child: Text('图片加载失败或不存在'))
              : _buildDesktopLayout(), // 使用更灵活的布局
    );
  }

  // 为桌面端/宽屏设计的左右分栏布局
  Widget _buildDesktopLayout() {
    final comments = context.watch<CommentProvider>().comments;
    final isLoadingComments = context.watch<CommentProvider>().isLoading;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧：图片展示区
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _image!.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        // 分隔线
        const VerticalDivider(width: 1, thickness: 1),
        // 右侧：信息与评论区
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    const Text(
                      '创作提示词',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _image!.prompt,
                        style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF333333)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLikeButton(),
                    const Divider(height: 48),
                    const Text(
                      '评论区',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (isLoadingComments)
                      const Center(child: CircularProgressIndicator())
                    else if (comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text('暂无评论，快来抢沙发吧！', style: TextStyle(color: Colors.grey))),
                      )
                    else
                      ...comments.map((comment) => CommentTile(comment: comment)),
                  ],
                ),
              ),
              // 底部评论输入框
              _buildCommentInputField(),
            ],
          ),
        ),
      ],
    );
  }

  // 封装点赞按钮，以便样式复用
  Widget _buildLikeButton() {
    return InkWell(
      onTap: _toggleLike,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _image!.liked ? Icons.favorite : Icons.favorite_border,
              color: _image!.liked ? Colors.redAccent : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              '点赞 (${_image!.likes ?? 0})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // 封装评论输入框
  Widget _buildCommentInputField() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: '说点什么...',
                fillColor: const Color(0xFFF7F8FA),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _postComment(),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: _postComment,
          ),
        ],
      ),
    );
  }
}
