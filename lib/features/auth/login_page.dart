import 'package:material_ui/material_ui.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../../shared/widgets/eco_art.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  void _login() {
    if (_form.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      switchPage(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        const Positioned(
          top: -25,
          left: -15,
          child: RotatedBox(
            quarterTurns: 1,
            child: LeafSprig(width: 104, height: 118),
          ),
        ),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: PloggrLogo(size: 70)),
                      const SizedBox(height: 35),
                      const Text('Welcome back!', style: AppText.title),
                      const SizedBox(height: 6),
                      const Text(
                        'Log in to continue your\nplogging journey 🌱',
                        style: AppText.body,
                      ),
                      const SizedBox(height: 24),
                      AppField(
                        label: 'Email or Phone Number',
                        icon: Icons.mail_outline_rounded,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter an email or phone number'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AppField(
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        password: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter a sample password'
                            : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => previewNotice(
                            context,
                            'Password recovery',
                            'This is an offline preview. Password recovery will be available when authentication is connected.',
                          ),
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      PrimaryButton('Login', onPressed: _login),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Flexible(
                            flex: 3,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or continue with',
                                textAlign: TextAlign.center,
                                style: AppText.caption,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _social(
                            'Google',
                            const Text(
                              'G',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4285F4),
                                fontSize: 25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _social(
                            'Apple',
                            const Icon(
                              Icons.apple,
                              color: AppColors.ink,
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _social(
                            'Phone',
                            const Icon(
                              Icons.phone_rounded,
                              color: AppColors.primary,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: AppText.caption,
                          ),
                          TextButton(
                            onPressed: () =>
                                openPage(context, AppRoutes.signup),
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => switchPage(context, AppRoutes.home),
                        child: const Text('Explore the preview'),
                      ),
                      const PreviewNote(
                        text:
                            'UI preview only. Use sample details, not real credentials.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  Widget _social(String name, Widget icon) => Expanded(
    child: Semantics(
      label: 'Continue with $name',
      button: true,
      child: OutlinedButton(
        onPressed: () => previewNotice(
          context,
          '$name sign-in',
          'Social sign-in is not connected in this preview. Choose Explore the preview to look around.',
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(12),
        ),
        child: icon,
      ),
    ),
  );
}
