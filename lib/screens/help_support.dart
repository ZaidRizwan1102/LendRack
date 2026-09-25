import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/custom_button.dart';
import 'package:wallet/widgets/custom_input_field.dart';

class HelpSupport extends StatefulWidget {
  const HelpSupport({super.key});

  @override
  State<HelpSupport> createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill email field with logged-in user's email if present
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail != null && currentUserEmail.isNotEmpty) {
      _emailController.text = currentUserEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    // 1. Validation
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
      return;
    }

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your message or feedback.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final timestamp = FieldValue.serverTimestamp();

      // 2. Save Feedback Record into Firestore
      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': userId,
        'userEmail': email,
        'message': message,
        'recipient': 'zaidrzw99@gmail.com',
        'createdAt': timestamp,
        'status': 'unread',
      });

      // 3. Queue Email Delivery (Compatible with 'Trigger Email' Firebase Extension)
      await FirebaseFirestore.instance.collection('mail').add({
        'to': ['zaidrzw99@gmail.com'],
        'message': {
          'subject': 'LendWise Support Request from $email',
          'text': 'User Email: $email\nUser ID: $userId\n\nMessage:\n$message',
          'html': '''
            <h2>New Support Ticket / Feedback</h2>
            <p><strong>From:</strong> $email</p>
            <p><strong>User ID:</strong> $userId</p>
            <hr />
            <p><strong>Message:</strong></p>
            <p>${message.replaceAll('\n', '<br>')}</p>
          ''',
        },
      });

      if (!mounted) return;

      // 4. Reset & Notify User
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Feedback sent successfully! We will get back to you soon."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send feedback: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final move = AppHandler(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => move.goBack(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    SizedBox(width: size.widthPerc(12)),
                    const Text(
                      "Help & Support",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.heightPerc(2.5)),

                // Main Form Card Box
                Padding(
                  padding: EdgeInsets.all(size.widthPerc(5)),
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
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Navy Left Border Strip
                          Container(
                            width: 5,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          // Inner Card Content
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(size.widthPerc(5)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title with Icon
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_rounded,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        size: 22,
                                      ),
                                      SizedBox(width: size.widthPerc(3)),
                                      Expanded(
                                        child: Text(
                                          "Send us a question or feedback",
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            height: 1.25,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.heightPerc(1.5)),

                                  // Description Subtitle
                                  Text(
                                    "Having trouble balancing your ledger? Found a bug? Let our team know how we can improve LendWise.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.4,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: size.heightPerc(2.5)),

                                  // Email Address Label
                                  Text(
                                    "Email Address",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  SizedBox(height: size.heightPerc(2)),

                                  // Email Input Field
                                  CustomInputField(
                                    controller: _emailController,
                                    hintText: "your@email.com",
                                    customWidth: double.infinity,
                                    margin: EdgeInsets.zero,
                                  ),

                                  SizedBox(height: size.heightPerc(2)),

                                  Text(
                                    "Your Message",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                  ),

                                  SizedBox(height: size.heightPerc(2)),
                                  // Message Input Field
                                  CustomInputField(
                                    controller: _messageController,
                                    hintText: "How can we help?",
                                    maxLines: 5,
                                    customWidth: double.infinity,
                                    margin: EdgeInsets.zero,
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
                SizedBox(height: size.heightPerc(18)),

                // Action Button
                if (_isSubmitting)
                  const Center(child: CircularProgressIndicator())
                else
                  CustomButton(
                    moveTo: _submitFeedback,
                    buttonText: "Send Feedback",
                    trailingIcon: Icons.send,
                  ),
                SizedBox(height: size.heightPerc(5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}