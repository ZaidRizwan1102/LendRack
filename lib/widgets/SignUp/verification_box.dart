import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/custom_button.dart';

class VerificationBox extends StatefulWidget {
  final String email;
  final VoidCallback onVerified;
  final VoidCallback? onChangeEmail;
  final VoidCallback? onCancel;

  const VerificationBox({
    super.key,
    required this.email,
    required this.onVerified,
    this.onChangeEmail,
    this.onCancel,
  });

  @override
  State<VerificationBox> createState() => _VerificationBoxState();
}

class _VerificationBoxState extends State<VerificationBox> {
  Timer? _timer;
  bool _isVerified = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  Future<void> _checkEmailVerified() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();

      if (user != null && user.emailVerified && !_isVerified) {
        _timer?.cancel();
        if (mounted) {
          setState(() {
            _isVerified = true;
          });
        }

        // Show green tick for 1.5s before triggering navigation
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          widget.onVerified();
        }
      }
    } catch (_) {
      // Catch network drops gracefully without crashing the loop
    }
  }

  Future<void> _resendEmail() async {
    if (_isResending) return;
    setState(() => _isResending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email sent! Check inbox & spam.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ?? 'Failed to resend. Please wait a minute.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(size.widthPerc(3)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: size.widthPerc(0.2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.widthPerc(5),
            vertical: size.heightPerc(3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isVerified
                    ? "Email Verified Successfully!"
                    : "Waiting for ${widget.email}\nto be verified...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),

              // Animated Transition
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: _isVerified
                    ? Container(
                        key: const ValueKey('verified_tick'),
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 32,
                        ),
                      )
                    : const CircularProgressIndicator(
                        key: ValueKey('loading_spinner'),
                      ),
              ),

              const SizedBox(height: 20),

              if (!_isVerified) ...[
                // Spam Notice
                Text(
                  "Don't see the email? Please check your Spam or Junk folder.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),

                // Primary Action: Resend Email
                CustomButton(
                  buttonText: _isResending ? "Sending..." : "Resend Email",
                  moveTo: _resendEmail,
                  width: double.infinity,
                  fontSize: 14,
                  buttonColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),

                // Secondary Actions: Change Email or Cancel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed:
                          widget.onChangeEmail ?? () => Navigator.pop(context),
                      child: Text(
                        "Change Email",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          widget.onCancel ?? () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}