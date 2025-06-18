import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/image_item.dart';
import '../models/comment.dart';
import '../providers/comment_provider.dart';
import '../services/image_service.dart';
import '../services/comment_service.dart';
import '../widgets/like_button.dart';
import '../widgets/comment_tile.dart';

class ImageDetailPage extends StatefulWidget {
  final String imageId;

  const ImageDetailPage({Key? key, required this.imageId}) : super(key: key);

  @override
  _ImageDetailPageState createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  ImageItem? _image;
  bool _loading = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadImageDetail();
  }

  Future<void> _loadImageDetail() async {
    setState(() {
      _loading = true;
    });
    try {
      final image = await ImageService.getImageDetail(widget.imageId);
      setState(() {
        _image = image;
      });
      await _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载图片详情失败: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await CommentService.getComments(widget.imageId);
      Provider.of<CommentProvider>(
        context,
        listen: false,
      ).setComments(comments);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载评论失败: $e')));
    }
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入评论内容')));
      return;
    }

    try {
      final comment = await CommentService.addComment(widget.imageId, content);
      Provider.of<CommentProvider>(
        context,
        listen: false,
      ).addCommentSync(comment);
      _commentController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('评论成功')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('发表评论失败: $e')));
    }
  }

  Future<void> _toggleLike() async {
    if (_image == null) return;

    try {
      final liked = await ImageService.toggleLike(_image!.imageId);
      setState(() {
        _image = _image!.copyWith(
          liked: liked,
          likes: liked ? (_image!.likes ?? 0) + 1 : (_image!.likes ?? 1) - 1,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('点赞失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final comments = Provider.of<CommentProvider>(context).comments;
    final isLoadingComments = Provider.of<CommentProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('图片详情')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _image == null
              ? const Center(child: Text('未找到图片'))
              : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Image.network(_image!.imageUrl),
                        const SizedBox(height: 12),
                        Text(
                          _image!.prompt,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        LikeButton(
                          liked: _image!.liked,
                          count: _image!.likes ?? 0,
                          onTap: _toggleLike,
                        ),
                        const Divider(height: 32),
                        const Text(
                          '评论',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isLoadingComments)
                          const Center(child: CircularProgressIndicator())
                        else if (comments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('暂无评论，快来抢沙发吧！'),
                          )
                        else
                          ...comments.map(
                            (comment) => CommentTile(comment: comment),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: '说点什么...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _postComment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
