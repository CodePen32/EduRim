import 'package:flutter/material.dart';
import '../../../core/i18n/app_strings.dart';
import '../widgets/info_widgets.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      appBarTitle: tr('terms.title'),
      children: [
        InfoHero(icon: Icons.description_rounded, title: tr('terms.title'), subtitle: tr('terms.heroSubtitle')),
        const SizedBox(height: 18),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Term(tr('terms.t1title'), tr('terms.t1body')),
              const Divider(height: 22),
              _Term(tr('terms.t2title'), tr('terms.t2body')),
              const Divider(height: 22),
              _Term(tr('terms.t3title'), tr('terms.t3body')),
              const Divider(height: 22),
              _Term(tr('terms.t4title'), tr('terms.t4body')),
              const Divider(height: 22),
              _Term(tr('terms.t5title'), tr('terms.t5body')),
            ],
          ),
        ),
      ],
    );
  }
}

class _Term extends StatelessWidget {
  final String title;
  final String body;
  const _Term(this.title, this.body);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14.5, fontWeight: FontWeight.bold), textAlign: TextAlign.start),
        const SizedBox(height: 6),
        InfoPara(body),
      ],
    );
  }
}
