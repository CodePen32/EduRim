import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_strings.dart';
import '../widgets/info_widgets.dart';

class ContactHistoryScreen extends StatelessWidget {
  const ContactHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      appBarTitle: tr('contact.title'),
      children: [
        InfoHero(icon: Icons.contact_page_rounded, title: tr('contact.title'), subtitle: tr('contact.heroSubtitle')),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
                child: const Icon(Icons.forum_outlined, size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              Text(
                tr('contact.empty'),
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  tr('contact.emptyBody'),
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13.5, height: 1.8, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
