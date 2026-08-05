import 'package:flutter/material.dart';
import '../home/home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          /// Orange Shape
          ClipPath(
            clipper: OrangeClipper(),
            child: Container(height: 320, color: const Color(0xffFF8A00)),
          ),

          /// Yellow Shape
          ClipPath(
            clipper: YellowClipper(),
            child: Container(height: 230, color: const Color(0xffFFF84A)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 170),

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

                    const SizedBox(height: 55),

                    Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: "Username",
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 22,
                            ),
                            suffixIcon: const Icon(
                              Icons.account_circle_outlined,
                              color: Colors.black,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 22,
                            ),
                            suffixIcon: const Icon(
                              Icons.visibility_outlined,
                              color: Colors.black,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Forget Password?",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        const SizedBox(height: 45),

                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
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
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: const Color(0xffFFE8C6),
                              child: Icon(Icons.g_mobiledata, size: 36),
                            ),

                            const SizedBox(width: 28),

                            CircleAvatar(
                              radius: 35,
                              backgroundColor: const Color(0xffFFE8C6),
                              child: const Icon(
                                Icons.mail,
                                color: Colors.red,
                                size: 38,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 45),

                        RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 18),
                            children: [
                              TextSpan(text: "Don’t have a account? "),
                              TextSpan(
                                text: "Sign up",
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
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
