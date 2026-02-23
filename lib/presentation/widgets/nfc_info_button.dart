import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A reusable info icon button that shows an overlay dialog with a message and an optional URL.
///
/// Usage:
/// ```dart
/// NfcInfoButton(
///   message: 'Some info text.',
///   url: 'https://example.com',
/// )
/// ```
class NfcInfoButton extends StatelessWidget {
  final String message;
  final String? url;
  final String title;

  const NfcInfoButton({
    super.key,
    required this.message,
    this.url,
    this.title = 'NFCタグについて',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      tooltip: title,
      onPressed: () => _showInfoDialog(context),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (url != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _launchUrl(url!),
                  child: Text(
                    url!,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
