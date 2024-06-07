import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/l10n/locale_provider.dart';
import 'package:v1_rentals/generated/l10n.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).language),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${S.of(context).select_language} :',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading:
                        Image.asset('assets/languages/united-kingdom-flag.png'),
                    title: Text(S.of(context).english),
                    onTap: () {
                      localeProvider.setLocale(const Locale('en'));
                      Navigator.pop(context); // Close Language screen
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Image.asset('assets/languages/china-flag.png'),
                    title: Text(S.of(context).chinese),
                    onTap: () {
                      localeProvider.setLocale(const Locale('zh'));
                      Navigator.pop(context); // Close Language screen
                    },
                  ),
                  // Add more language options as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
