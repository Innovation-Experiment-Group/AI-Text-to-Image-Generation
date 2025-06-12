import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/validator.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nickname = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await AuthService.register(
        username: _username.text,
        password: _password.text,
        email: _email.text,
        nickname: _nickname.text,
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('注册失败：$e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: '用户名'),
                validator: Validator.validateUsername,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: '邮箱'),
                validator: Validator.validateEmail,
              ),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true,
                validator: Validator.validatePassword,
              ),
              TextFormField(
                controller: _nickname,
                decoration: const InputDecoration(labelText: '昵称（可选）'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child:
                    _loading
                        ? const CircularProgressIndicator()
                        : const Text('注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
