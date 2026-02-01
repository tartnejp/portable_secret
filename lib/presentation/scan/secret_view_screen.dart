import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/value_objects/secret_data.dart';

class SecretViewScreen extends StatelessWidget {
  final SecretData secret;
  const SecretViewScreen({super.key, required this.secret});

  Widget _buildValueText(BuildContext context, String value) {
    // Check if the value is a valid URL
    final isUrl = value.startsWith('http://') || value.startsWith('https://');

    if (isUrl) {
      return InkWell(
        onTap: () async {
          final uri = Uri.tryParse(value);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('URLを開けませんでした')));
            }
          }
        },
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    } else {
      return SelectableText(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('復号された情報'),
        automaticallyImplyLeading: false, // AppBarの戻るボタンを非表示
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: secret.items.length,
              itemBuilder: (context, index) {
                final item = secret.items[index];
                return ListTile(
                  title: SelectableText(item.key),
                  subtitle: _buildValueText(context, item.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: item.value));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.key}をコピーしました'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.goNamed('HOM');
                },
                child: const Text('ホーム画面に戻る'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
