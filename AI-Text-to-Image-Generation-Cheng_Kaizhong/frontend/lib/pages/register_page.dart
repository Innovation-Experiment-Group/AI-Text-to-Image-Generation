import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _confirmPassword = '';
  String _email = '';
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_password != _confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('两次密码不一致')));
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await AuthService.register(_username, _password, _email);
      final userJson = res['data'];
      final token = res['token'];

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(User.fromJson(userJson), token: token);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      final msg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧图片
          Expanded(
            child: Image.asset(
              'assets/register.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
          // 右侧表单
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
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          const Text(
                            '注册',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            decoration: const InputDecoration(labelText: '用户名'),
                            validator:
                                (v) => v == null || v.isEmpty ? '请输入用户名' : null,
                            onSaved: (v) => _username = v!.trim(),
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: '邮箱'),
                            keyboardType: TextInputType.emailAddress,
                            validator:
                                (v) => v == null || v.isEmpty ? '请输入邮箱' : null,
                            onSaved: (v) => _email = v!.trim(),
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: '密码'),
                            obscureText: true,
                            validator:
                                (v) => v == null || v.isEmpty ? '请输入密码' : null,
                            onSaved: (v) => _password = v!.trim(),
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: '确认密码',
                            ),
                            obscureText: true,
                            validator:
                                (v) => v == null || v.isEmpty ? '请确认密码' : null,
                            onSaved: (v) => _confirmPassword = v!.trim(),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loading ? null : _register,
                            child:
                                _loading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text('注册'),
                          ),
                          TextButton(
                            onPressed:
                                () => Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                ),
                            child: const Text('已有账号？去登录'),
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
    );
  }
}
