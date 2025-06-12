import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/image_service.dart';
import '../services/comment_service.dart';
import '../utils/constants.dart';
import '../models/image_item.dart';
import '../models/comment.dart';
import '../widgets/comment_tile.dart';
import '../widgets/like_button.dart';

class ImageDetailPage extends StatefulWidget {
  final String imageId;

  const ImageDetailPage({super.key, required this.imageId});

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  ImageItem? _image;
  List<Comment> _comments = [];
  bool _liked = false;
  int _likeCount = 0;
  final _commentController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(Constants.tokenKey);
      final image = await ImageService.getImageDetail(
        widget.imageId,
        token: token,
      );
      final comments = await CommentService.getComments(
        widget.imageId,
        token: token,
      );
      // TODO: 点赞状态需调用接口，这里简单用图片数据模拟
      setState(() {
        _image = image;
        _comments = comments;
        _liked = false; // 默认为未点赞（你可用点赞服务替换）
        _likeCount = image.likes ?? 0;
      });
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('加载失败')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constants.tokenKey);
    if (token == null) return;

    try {
      final comment = await CommentService.addComment(
        imageId: widget.imageId,
        content: content,
        token: token,
      );
      setState(() {
        _comments.insert(0, comment);
        _commentController.clear();
      });
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('评论失败')));
    }
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
    // 实际应调用点赞接口
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图片详情')),
      body:
          _loading || _image == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Image.network(_image!.imageUrl),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                _image!.user?.avatarUrl ?? '',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(_image!.user?.nickname ?? '匿名用户'),
                            const Spacer(),
                            LikeButton(
                              liked: _liked,
                              count: _likeCount,
                              onTap: _toggleLike,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _image!.prompt,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Divider(),
                        const Text(
                          '评论',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._comments.map((c) => CommentTile(comment: c)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: '写评论...',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendComment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
