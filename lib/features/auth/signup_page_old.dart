import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:ploggr/features/auth/login_page.dart';
import 'package:ploggr/features/home/home_page.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// Orange Shape
          SizedBox(
            width: double.infinity,
            height: screenWidth * 0.8,
            child: ClipPath(
              clipper: OrangeClipper(),
              child: Container(
                width: double.infinity,
                color: const Color(0xffFF8A00),
              ),
            ),
          ),

          /// Yellow Shape
          SizedBox(
            width: double.infinity,
            height: screenWidth * 0.58,
            child: ClipPath(
              clipper: YellowClipper(),
              child: Container(
                width: double.infinity,
                color: const Color(0xffFFF84A),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.10, // Slightly increased padding for the form
                  vertical: screenWidth * 0.10,
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenWidth * 0.42),

                    // Title
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    // Underline
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 100,
                      height: 3,
                      color: Colors.orange,
                    ),

                    SizedBox(height: screenWidth * 0.10),

                    // Form Fields
                    Column(
                      children: [
                        _buildTextField(
                          hintText: "Username - x23407",
                          icon: Icons.account_circle,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          hintText: "Real Name - John",
                          icon: Icons.badge,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          hintText: "Email id",
                          icon: Icons.mail_outline,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          hintText: "Password",
                          icon: Icons.visibility_outlined,
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          hintText: "Confirm Password",
                          icon: Icons.visibility_outlined,
                          isPassword: true,
                        ),

                        const SizedBox(height: 45),

                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignupPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffFF8A00),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                        SignUpFooter()

                        // Bottom Text (Replicated exactly from the image)
                        // RichText(
                        //   text: const TextSpan(
                        //     style: TextStyle(
                        //       color: Colors.lightBlue,
                        //       fontSize: 16,
                        //     ),
                        //     children: [
                        //       TextSpan(
                        //         text: "Don’t have a account? ",
                        //       ),
                        //       TextSpan(
                        //         text: "Sign up",
                        //         style: TextStyle(
                        //           decoration: TextDecoration.underline,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to keep the code clean and avoid repeating TextField configurations
  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 18,
        ),
        suffixIcon: Icon(
          icon,
          color: Colors.black,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.orange,
            width: 2,
          ),
        ),
      ),
    );
  }
}

// Retaining the Clippers from the original code
class OrangeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.88);
    path.lineTo(size.width * 0.24, size.height);
    path.lineTo(size.width * 0.62, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class YellowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.62, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.60);
    path.lineTo(size.width * 0.38, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class SignUpFooter extends StatefulWidget {
  const SignUpFooter({super.key});

  @override
  State<SignUpFooter> createState() => _SignUpFooterState();
}

class _SignUpFooterState extends State<SignUpFooter> {
  late final TapGestureRecognizer _signUpRecognizer;

  @override
  void initState() {
    super.initState();
    _signUpRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      };
  }

  @override
  void dispose() {
    _signUpRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.lightBlue,
          fontSize: 16,
        ),
        children: [
          const TextSpan(
            text: "Don't have a account? ",
          ),
          TextSpan(
            text: "Log In",
            style: const TextStyle(
              decoration: TextDecoration.underline,
            ),
            recognizer: _signUpRecognizer,
          ),
        ],
      ),
    );
  }
}