import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas/provider/auth_provider.dart';
import 'package:uas/utils/auth_status.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _fullnameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: 1.5),
  );

  void _tapToRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullname = _fullnameController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      final authProvider = context.read<AuthProvider>();
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      await authProvider.createAccount(fullname, email, password);
      if (authProvider.authStatus == AuthStatus.accountCreated) {
        navigator.pop();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              authProvider.message ?? "",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      const message = "Masukkan nama, email dan password dengan benar";
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
    }
  }

  void _goToLogin() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _fullnameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1665D8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ajari',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1665D8),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                const Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lorem ipsum dolor sit amet, consectetur\nadipiscing elit, sed do eiusmod',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // Name field - orange border when focused to match design
                TextField(
                  controller: _fullnameController,
                  focusNode: _fullnameFocus,
                  decoration: InputDecoration(
                    hintText: 'Full name',
                    hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                    filled: true,
                    fillColor: const Color(0xFFFFFFFF),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: _border(const Color(0xFFDDDDDD)),
                    enabledBorder: _border(const Color(0xFFDDDDDD)),
                    focusedBorder: _border(
                      const Color(0xFFF97316),
                    ), // orange when focused
                  ),
                ),
                const SizedBox(height: 12),

                // Email field
                TextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                    filled: true,
                    fillColor: const Color(0xFFFFFFFF),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: _border(const Color(0xFFDDDDDD)),
                    enabledBorder: _border(const Color(0xFFDDDDDD)),
                    focusedBorder: _border(const Color(0xFF1665D8)),
                  ),
                ),
                const SizedBox(height: 12),

                // Password field
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                    filled: true,
                    fillColor: const Color(0xFFFFFFFF),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: _border(const Color(0xFFDDDDDD)),
                    enabledBorder: _border(const Color(0xFFDDDDDD)),
                    focusedBorder: _border(const Color(0xFF1665D8)),
                  ),
                ),

                const SizedBox(height: 24),

                // Create My Account Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _tapToRegister(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'CREATE MY ACCOUNT',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'By tapping Sign up you accept all our terms and condition',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                ),

                const SizedBox(height: 24),

                // Already have account + Sign in button
                Column(
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF2FC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () => _goToLogin(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: const Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: Color(0xFF1665D8),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
