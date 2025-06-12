import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/generate_page.dart';
import 'pages/image_detail_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI画廊',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/generate': (context) => const GeneratePage(),
        // image_detail 需要传参数，建议用 onGenerateRoute 处理，这里简单示范空页面
        '/profile': (context) => const ProfilePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/image_detail') {
          final args = settings.arguments as Map<String, dynamic>?;
          final imageId = args?['imageId'];
          if (imageId != null) {
            return MaterialPageRoute(
              builder: (context) => ImageDetailPage(imageId: imageId),
            );
          }
        }
        return null; // 未匹配时返回 null
      },
    );
  }
}
//在页面跳转时写：Navigator.pushNamed(context, '/image_detail', arguments: {'imageId': 123});