import 'package:flutter/material.dart';
import 'package:wallet/screens/home_page.dart';
import 'package:wallet/screens/signup.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/continue_with.dart';
import 'package:wallet/widgets/Login/forget_password.dart';
import 'package:wallet/widgets/Login/info_container.dart';
import 'package:wallet/widgets/Login/sign_back_buttons.dart';
import 'package:wallet/widgets/custom_snackbar.dart';
import 'package:wallet/widgets/google_button.dart';
import 'package:wallet/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    CustomSnackBar.show(context, message: message);
  }

Future<void> _handleSignIn() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    _showSnackBar("Please fill in all required fields");
    return;
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(email)) {
    _showSnackBar("Please enter a valid email address");
    return;
  }

  setState(() => _isLoading = true);

  try {
    await AuthService().signInWithEmail(email: email, password: password);
    
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null && !user.emailVerified) {
      _showSnackBar("Please verify your email before logging in.");
      await FirebaseAuth.instance.signOut(); // Log them back out
      return;
    }

    if (mounted) {
      final handler = AppHandler(context);
      handler.toPage(const HomePage()); // Clears navigation stack
    }
  } catch (e) {
    if (mounted) {
      _showSnackBar(e.toString());
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final move = AppHandler(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Image(
                image: AssetImage(
                isDark 
                  ? 'assets/images/logo_dark.png'
                  : 'assets/images/logo_light.png'
                  ),
                height: size.heightPerc(10),
              ),
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: size.heightPerc(1.5)),
              Text(
                "Sign in to manage your records",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              SizedBox(height: size.heightPerc(3)),
              // Pass controllers to InfoContainer
              InfoContainer(
                emailController: _emailController,
                passwordController: _passwordController,
              ),

              SizedBox(height: size.heightPerc(1)),
              const ForgetPassword(),
              SizedBox(height: size.heightPerc(1.2)),

              // Show loader or pass callback to button
              _isLoading
                  ? const CircularProgressIndicator()
                  : SignBackButtons(onSignInPressed: _handleSignIn),
              SizedBox(height: size.heightPerc(4)),
              const ContinueWith(),
              SizedBox(height: size.heightPerc(4)),
              const GoogleButton(),
              SizedBox(height: size.heightPerc(2)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      move.toPage(const Signup());
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
