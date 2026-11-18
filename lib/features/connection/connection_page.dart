import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';
import 'connection_controller.dart';
import 'connection_service.dart';

class ConnectionPage extends ConsumerWidget {
  const ConnectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectionCheckProvider);
    final checking = status == ConnectionCheckStatus.checking;
    final configured = status != ConnectionCheckStatus.notConfigured;
    final (title, message) = switch (status) {
      ConnectionCheckStatus.notConfigured => (
        'No server configured',
        'Open the app with a configured server to check its connection. '
            'You can keep exploring the preview.',
      ),
      ConnectionCheckStatus.idle => (
        'Ready to check',
        'Check the app’s connection to the server and database.',
      ),
      ConnectionCheckStatus.checking => (
        'Checking connection…',
        'Contacting the server and checking its database.',
      ),
      ConnectionCheckStatus.connected => (
        'Connected',
        'The server and its database are available.',
      ),
      ConnectionCheckStatus.databaseUnavailable => (
        'Database unavailable',
        'The server responded, but its database check did not pass. Try again shortly.',
      ),
      ConnectionCheckStatus.timedOut => (
        'Connection timed out',
        'The server took too long to respond. Check your connection and try again.',
      ),
      ConnectionCheckStatus.invalidResponse => (
        'Unexpected server response',
        'The server’s response could not confirm a working connection.',
      ),
      ConnectionCheckStatus.httpError => (
        'Server check failed',
        'The server could not complete this check. Check the server configuration and try again.',
      ),
      ConnectionCheckStatus.unreachable => (
        'Server unavailable',
        'Could not reach the server. Check your connection and server address, then try again.',
      ),
      ConnectionCheckStatus.cancelled => (
        'Check cancelled',
        'You can check the connection again.',
      ),
    };

    return AppPage(
      title: 'Connection check',
      backTo: AppRoutes.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EcoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (checking)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Checking connection',
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Icon(
                      status == ConnectionCheckStatus.connected
                          ? Icons.check_circle_outline
                          : Icons.network_check,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                Text(title, style: AppText.heading),
                const SizedBox(height: 8),
                Text(message),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            checking
                ? 'Checking…'
                : status == ConnectionCheckStatus.idle || !configured
                ? 'Check connection'
                : 'Check again',
            onPressed: checking || !configured
                ? null
                : () => ref.read(connectionCheckProvider.notifier).check(),
          ),
          const SizedBox(height: 16),
          const Text(
            'This check contacts the configured server. '
            'Your preview activity and profile details stay on this device.',
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}
