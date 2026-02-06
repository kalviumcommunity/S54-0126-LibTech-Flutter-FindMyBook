import 'package:flutter/material.dart';
import '../../domain/usecases/sign_in.dart';
import '../../data/repositories/auth_repository_impl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  String? _error;

  final _passFocus = FocusNode();
  String? _errorMessage;


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
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    final repo = AuthRepositoryImpl();
    final usecase = SignIn(repo);
    try {
      await usecase.call(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed in')));
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());

      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _extractErrorMessage(e));

    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _extractErrorMessage(Object e) {
    final s = e.toString();
    if (s.startsWith('Exception: ')) return s.replaceFirst('Exception: ', '');
    return s;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();

    _emailFocus.dispose();

    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: TextStyle(color: Colors.red.shade800))),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => setState(() => _error = null),

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20, color: Colors.red),
                          onPressed: () => setState(() => _errorMessage = null),

                        )
                      ],
                    ),
                  ),
                TextFormField(
                  controller: _emailCtrl,

                  focusNode: _emailFocus,


                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passFocus),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  focusNode: _passFocus,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: _validatePassword,

                  onFieldSubmitted: (_) => _submit(),

                  onFieldSubmitted: (_) => _loading ? null : _submit(),

                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading

                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white))

                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))

                      : const Text('Login'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading ? null : () => Navigator.of(context).pushReplacementNamed('/register'),
                  child: const Text('Don\'t have an account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
