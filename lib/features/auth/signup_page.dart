import 'package:material_ui/material_ui.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      switchPage(context, AppRoutes.home);
      toast(context, 'Welcome to the preview. No account was created.');
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: '',
    backTo: AppRoutes.login,
    child: Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          const Text(
            'Sign Up',
            style: AppText.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text('Create your ploggr account', textAlign: TextAlign.center),
          const SizedBox(height: 30),
          AppField(
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
            validator: _required,
          ),
          const SizedBox(height: 14),
          AppField(
            label: 'Email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value != null &&
                    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
                ? null
                : 'Enter a valid sample email',
          ),
          const SizedBox(height: 14),
          AppField(
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) =>
                (value ?? '').replaceAll(RegExp(r'\D'), '').length >= 7
                ? null
                : 'Enter a valid sample phone number',
          ),
          const SizedBox(height: 14),
          AppField(
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            password: true,
            controller: _password,
            validator: (value) =>
                (value ?? '').length >= 8 ? null : 'Use at least 8 characters',
          ),
          const SizedBox(height: 14),
          AppField(
            label: 'Confirm Password',
            icon: Icons.lock_outline_rounded,
            password: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (value) =>
                value == _password.text && (value ?? '').isNotEmpty
                ? null
                : 'Passwords must match',
          ),
          const SizedBox(height: 30),
          PrimaryButton('Create Account', onPressed: _submit),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Already have an account?', style: AppText.caption),
              TextButton(
                onPressed: () => switchPage(context, AppRoutes.login),
                child: const Text('Login'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const PreviewNote(
            text:
                'Preview only · no account is created or details stored.\nPlease use fictional details.',
          ),
        ],
      ),
    ),
  );
  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Enter a sample name' : null;
}
