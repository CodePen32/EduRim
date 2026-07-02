import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../widgets/info_widgets.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = <List<String>>[
      [tr('faq.q1'), tr('faq.a1')],
      [tr('faq.q2'), tr('faq.a2')],
      [tr('faq.q3'), tr('faq.a3')],
      [tr('faq.q4'), tr('faq.a4')],
      [tr('faq.q5'), tr('faq.a5')],
      [tr('faq.q6'), tr('faq.a6')],
    ];
    return InfoScaffold(
      appBarTitle: tr('faq.title'),
      children: [
        InfoHero(icon: Icons.help_rounded, title: tr('faq.title'), subtitle: tr('faq.heroSubtitle')),
        const SizedBox(height: 16),
        ...faqs.map((qa) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InfoCard(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    iconColor: AppColors.primary,
                    collapsedIconColor: AppColors.textLight,
                    title: Text(
                      qa[0],
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      textAlign: TextAlign.start,
                    ),
                    children: [InfoPara(qa[1])],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
