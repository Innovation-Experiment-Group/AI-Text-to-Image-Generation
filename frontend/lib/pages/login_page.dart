import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/validator.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final res = await AuthService.login(
        username: _username.text,
        password: _password.text,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.tokenKey, res['token']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('登录失败：$e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: '用户名'),
                validator: Validator.validateUsername,
              ),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true,
                validator: Validator.validatePassword,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child:
                    _loading
                        ? const CircularProgressIndicator()
                        : const Text('登录'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                child: const Text('没有账号？注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
