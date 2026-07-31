import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nutri_nepal/app/theme/app_colors.dart';
import 'package:nutri_nepal/core/api/api_client.dart';
import 'package:nutri_nepal/core/api/api_endpoints.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _api = ApiClient();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _email.text.trim();
    if (email.isEmpty) return;
    setState(() => _loading = true);
    try {
      await _api.post(ApiEndpoints.forgotPassword, data: {'email': email});
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: email)),
      );
    } on DioException catch (error) {
      if (!mounted) return;
      final data = error.response?.data;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data is Map ? '${data['message']}' : 'Could not send the reset code.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthPage(
      title: 'Forgot password?',
      subtitle: 'Enter your email and we will send you a reset code.',
      children: [
        TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: _decoration('Email address', Icons.email_outlined)),
        const SizedBox(height: 20),
        _PrimaryButton(label: 'Send reset code', loading: _loading, onPressed: _sendCode),
      ],
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _api = ApiClient();
  bool _loading = false;

  @override
  void dispose() { _code.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _reset() async {
    setState(() => _loading = true);
    try {
      await _api.post(ApiEndpoints.resetPassword, data: {'email': widget.email, 'code': _code.text.trim(), 'password': _password.text});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset. You can log in now.')));
      Navigator.popUntil(context, (route) => route.isFirst);
    } on DioException catch (error) {
      if (!mounted) return;
      final data = error.response?.data;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data is Map ? '${data['message']}' : 'Could not reset password.')));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthPage(
      title: 'Reset password',
      subtitle: 'Enter the six-digit code sent to ${widget.email}.',
      children: [
        TextField(controller: _code, keyboardType: TextInputType.number, maxLength: 6, decoration: _decoration('Reset code', Icons.pin_outlined)),
        const SizedBox(height: 8),
        TextField(controller: _password, obscureText: true, decoration: _decoration('New password', Icons.lock_outline)),
        const SizedBox(height: 20),
        _PrimaryButton(label: 'Reset password', loading: _loading, onPressed: _reset),
      ],
    );
  }
}

class _AuthPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const _AuthPage({required this.title, required this.subtitle, required this.children});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.appBackground,
    appBar: AppBar(backgroundColor: AppColors.appBackground, foregroundColor: AppColors.white, title: const Text('NutriNepal')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 40), Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.white, fontFamily: 'Montserrat')),
      const SizedBox(height: 10), Text(subtitle, style: const TextStyle(color: AppColors.grey, fontFamily: 'OpenSans')),
      const SizedBox(height: 32), ...children,
    ])),
  );
}

class _PrimaryButton extends StatelessWidget {
  final String label; final bool loading; final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.loading, required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, child: ElevatedButton(onPressed: loading ? null : onPressed, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(label)));
}

InputDecoration _decoration(String hint, IconData icon) => InputDecoration(hintText: hint, prefixIcon: Icon(icon), filled: true, fillColor: AppColors.surfaceSoft, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none));
