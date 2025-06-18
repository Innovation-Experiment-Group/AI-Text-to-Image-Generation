import 'package:intl/intl.dart';

class DateUtilsHelper {
  /// 转换为 yyyy-MM-dd HH:mm 格式
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

  /// 计算相对时间（如“2小时前”）
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) return '刚刚';
    if (difference.inMinutes < 60) return '${difference.inMinutes}分钟前';
    if (difference.inHours < 24) return '${difference.inHours}小时前';
    if (difference.inDays < 7) return '${difference.inDays}天前';

    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
}
