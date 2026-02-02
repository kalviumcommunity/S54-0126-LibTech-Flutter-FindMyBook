import 'package:flutter/material.dart';
import '../../domain/usecases/sign_up.dart';
import '../../data/repositories/auth_repository_impl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final re = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
    if (!re.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final repo = AuthRepositoryImpl();
    final usecase = SignUp(repo);
    try {
      final uid = await usecase.call(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registered: $uid')));
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(onPressed: _submit, child: const Text('Register')),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
