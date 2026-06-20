import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/supabase_debug.dart';
import 'create_project_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    setState(() => _errorMessage = null);
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _handleVerify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter the full 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: code,
        type: OtpType.signup,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CreateProjectScreen()),
        );
      }
    } catch (e, stackTrace) {
      logSupabaseError('verify signup otp', e, stackTrace);

      setState(() => _errorMessage = 'Invalid or expired code. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code resent!')),
        );
      }
    } catch (e, stackTrace) {
      logSupabaseError('resend signup otp', e, stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to resend code. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60.0),

                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8.0),

                const Text(
                  "We've sent a verification code to your email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40.0),

                // 8 code input fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 44.0,
                      height: 52.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => _onChanged(value, index),
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1C1E),
                          height: 1.0,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
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
                    );
                  }),
                ),
                const SizedBox(height: 16.0),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 8.0),

                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2979FF),
                      disabledBackgroundColor: const Color(0xFF2979FF),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 22.0,
                      height: 22.0,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Verify Email',
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Didn't receive the code? ",
                      style: TextStyle(fontSize: 13.0, color: Colors.black45),
                    ),
                    InkWell(
                      onTap: _handleResend,
                      borderRadius: BorderRadius.circular(4.0),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                        child: Text(
                          'Resend',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
