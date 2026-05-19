import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEFF4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Center(
                  child: Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),

                // Subtitle
                const Center(
                  child: Text(
                    'Sign in to continue your projects',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),

                // Email label
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),

                // Email field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'you@example.com',
                    hintStyle: const TextStyle(
                      color: Colors.black38,
                      fontSize: 14.0,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF2979FF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Password label
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: const TextStyle(
                      color: Colors.black38,
                      fontSize: 14.0,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.black38,
                        size: 20.0,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF2979FF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),

                // Forgot Password
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to forgot password page
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2979FF),
                    ),
                  ),
                ),
                const SizedBox(height: 28.0),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Add Supabase sign in logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2979FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Icon(Icons.arrow_forward, size: 18.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Sign Up link
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: Colors.black45,
                      ),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Navigate to sign up page
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2979FF),
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
          ),
        ),
      ),
    );
  }
}