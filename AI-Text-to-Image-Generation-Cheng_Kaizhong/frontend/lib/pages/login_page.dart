import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);

    try {
      await Provider.of<UserProvider>(
        context,
        listen: false,
      ).login(_username, _password);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左半部分：背景图
          Expanded(
            child: Image.asset(
              'assets/login.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
          // 右半部分：登录表单
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI画廊',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 400,
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '登录',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: '用户名',
                                    ),
                                    validator:
                                        (v) =>
                                            (v == null || v.isEmpty)
                                                ? '请输入用户名'
                                                : null,
                                    onSaved: (v) => _username = v!.trim(),
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: '密码',
                                    ),
                                    obscureText: true,
                                    validator:
                                        (v) =>
                                            (v == null || v.isEmpty)
                                                ? '请输入密码'
                                                : null,
                                    onSaved: (v) => _password = v!.trim(),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _loading ? null : _login,
                                    child:
                                        _loading
                                            ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                            : const Text('登录'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pushNamed(
                                          context,
                                          '/register',
                                        ),
                                    child: const Text('没有账号？去注册'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
