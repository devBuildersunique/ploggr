import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:ploggr/routes/app_routes.dart';
import 'package:ploggr/shared/widgets/work_in_progress.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  bool _obscurePassword = true;

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
                  horizontal: screenWidth * 0.05,
                  vertical: screenWidth * 0.10,
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenWidth * 0.42),

                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 90,
                      height: 3,
                      color: Colors.orange,
                    ),

                    SizedBox(height: screenWidth * 0.14),

                    Column(
                      children: [
                        // TextField(
                        //   decoration: InputDecoration(
                        //     hintText: "Username",
                        //     hintStyle: const TextStyle(
                        //       color: Colors.grey,
                        //       fontSize: 22,
                        //     ),
                        //     suffixIcon: const Icon(
                        //       Icons.account_circle_outlined,
                        //       color: Colors.black,
                        //     ),
                        //     enabledBorder: const UnderlineInputBorder(
                        //       borderSide: BorderSide(color: Colors.black),
                        //     ),
                        //     focusedBorder: const UnderlineInputBorder(
                        //       borderSide: BorderSide(
                        //         color: Colors.orange,
                        //         width: 2,
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        _buildTextField(
                          hintText: "Username",
                          icon: Icons.account_circle,
                        ),

                        const SizedBox(height: 10),

                        _buildTextField(
                          hintText: "Password",
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onToggleVisibility: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => {
                              showWipPopup(
                                context,
                                title: "WIP",
                                description: "Need to add",
                              ),
                            },
                            child: Text(
                              "Forget Password?",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 45),

                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push(AppRoutes.home);
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
                              "Login",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          "or Login with",
                          style: TextStyle(fontSize: 20),
                        ),

                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => showCustomMessage(
                                context,
                                title: "NOT IMPLEMNTED",
                                description: "Waiting for the backend",
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: const Color(0xffFFE8C6),
                                child: const Icon(Icons.g_mobiledata, size: 36),
                              ),
                            ),

                            const SizedBox(width: 28),

                            TextButton(
                              onPressed: () => showCustomMessage(
                                context,
                                title: "Not Implemented",
                                description: "Waiting for the backend",
                              ),
                              child: const CircleAvatar(
                                radius: 35,
                                backgroundColor: Color(0xffFFE8C6),
                                child: Icon(
                                  Icons.mail,
                                  color: Colors.red,
                                  size: 38,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 45),

                        SignUpFooter(),

                        // RichText(
                        //   text: const TextSpan(
                        //     style: TextStyle(
                        //       color: Colors.black,
                        //       fontSize: 18,
                        //     ),
                        //     children: [
                        //       TextSpan(
                        //         text: "Don’t have a account? ",
                        //       ),
                        //       TextSpan(
                        //         text: "Sign up",
                        //         style: TextStyle(
                        //           color: Colors.blue,
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

  Widget _buildTextField({
    required String hintText,
    IconData icon = Icons.account_circle, // fallback for non-password fields
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return TextField(
      obscureText: isPassword ? obscureText : false,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black,
                ),
                onPressed: onToggleVisibility,
              )
            : Icon(icon, color: Colors.black),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
      ),
    );
  }
}

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
        context.push(AppRoutes.signup);
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
        style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
        children: [
          const TextSpan(text: "Don't have a account? "),
          TextSpan(
            text: "Sign up",
            style: const TextStyle(decoration: TextDecoration.underline),
            recognizer: _signUpRecognizer,
          ),
        ],
      ),
    );
  }
}
