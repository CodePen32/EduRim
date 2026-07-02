import 'package:flutter/material.dart';
import '../../../core/i18n/app_strings.dart';
import '../widgets/info_widgets.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      appBarTitle: tr('about.title'),
      children: [
        InfoHero(icon: Icons.school_rounded, title: 'Concouri', subtitle: tr('about.heroSubtitle')),
        const SizedBox(height: 18),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoPara(tr('about.p1')),
              const SizedBox(height: 12),
              InfoPara(tr('about.p2')),
              const SizedBox(height: 12),
              InfoPara(tr('about.p3')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoSectionTitle(icon: Icons.flag_rounded, title: tr('about.mission')),
              const SizedBox(height: 6),
              InfoPara(tr('about.missionBody')),
              const SizedBox(height: 14),
              InfoSectionTitle(icon: Icons.verified_rounded, title: tr('about.values')),
              const SizedBox(height: 6),
              InfoPara(tr('about.valuesBody')),
            ],
          ),
        ),
      ],
    );
  }
}
