import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wallet/screens/login.dart';
import 'package:wallet/services/auth.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/SignUp/signup_back_buttons.dart';
import 'package:wallet/widgets/SignUp/signup_info_container.dart';
import 'package:wallet/widgets/SignUp/verification_box.dart';
import 'package:wallet/widgets/continue_with.dart';
import 'package:wallet/widgets/custom_snackbar.dart';
import 'package:wallet/widgets/google_button.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    CustomSnackBar.show(context, message: message);
  }

  void _showVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return VerificationBox(
          email: email,
          onVerified: () {
            Navigator.of(dialogContext).pop();
            if (mounted) {
              AppHandler(context).toPage(Login());
            }
          },
          onChangeEmail: () async {
            Navigator.of(dialogContext).pop();
            await _cleanupUnverifiedUser();
          },
          onCancel: () async {
            Navigator.of(dialogContext).pop();
            await _cleanupUnverifiedUser();
          },
        );
      },
    );
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Please fill in all required fields");
      return;
    }

    if (password.length < 6) {
      _showSnackBar("Password must be at least 6 characters");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().signUpWithEmail(email: email, password: password);

      if (mounted) {
        _showVerificationDialog(email);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        _showSnackBar("The email address provided is invalid.");
      } else if (e.code == 'email-already-in-use') {
        _showSnackBar("An account already exists for this email.");
      } else if (e.code == 'weak-password') {
        _showSnackBar("Password must be at least 6 characters.");
      } else if (e.code == 'operation-not-allowed') {
        _showSnackBar("Email/Password sign-in is disabled in Firebase Console.");
      } else {
        _showSnackBar(e.message ?? "Sign up failed (${e.code}).");
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll("Exception: ", "");
      _showSnackBar(errorMessage);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cleanupUnverifiedUser() async {
    final user = FirebaseAuth.instance.currentUser;
    
    // Only clean up if the account was converted to email AND remains unverified.
    // Do NOT run this on anonymous guest sessions.
    if (user != null && !user.isAnonymous && !user.emailVerified) {
      try {
        await user.delete();
      } catch (_) {
        await FirebaseAuth.instance.signOut();
      }
      // Re-initialize guest auth so a valid anonymous session is restored
      await AuthService().initializeAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Center(
            child: Column(
              children: [
                Image(
                  image: AssetImage(
                    isDark
                        ? 'assets/images/logo_dark.png'
                        : 'assets/images/logo_light.png',
                  ),
                  height: size.heightPerc(10),
                ),
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: size.heightPerc(0.5)),
                Text(
                  "Backup your records by creating an account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                SizedBox(height: size.heightPerc(2)),

                SignupInfoContainer(
                  emailController: _emailController,
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                ),

                SizedBox(height: size.heightPerc(2)),

                _isLoading
                    ? const CircularProgressIndicator()
                    : SignupBackButtons(onSignupPressed: _handleSignUp),

                SizedBox(height: size.heightPerc(1.5)),
                const ContinueWith(),
                SizedBox(height: size.heightPerc(1)),
                const GoogleButton(),
                SizedBox(height: size.heightPerc(2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}