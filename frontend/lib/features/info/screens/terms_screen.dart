import 'package:flutter/material.dart';
import '../widgets/info_widgets.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      appBarTitle: 'شروط الاستخدام',
      children: const [
        InfoHero(icon: Icons.description_rounded, title: 'شروط الاستخدام', subtitle: 'يرجى قراءتها قبل استخدام التطبيق'),
        SizedBox(height: 18),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Term('1. الاستخدام الشخصي', 'يُستخدم التطبيق لأغراض تعليمية شخصية فقط. لا يجوز إعادة بيع أو توزيع المحتوى دون إذن.'),
              Divider(height: 22),
              _Term('2. الحساب', 'أنت مسؤول عن سرية بيانات حسابك. رقم الهاتف والبريد يُحدّدان عند التسجيل ولا يمكن تغييرهما لاحقاً من التطبيق.'),
              Divider(height: 22),
              _Term('3. المحتوى', 'كل الدروس والتمارين والمواضيع مملوكة للمنصة أو لأصحابها. يُمنع نسخها أو نشرها خارج التطبيق.'),
              Divider(height: 22),
              _Term('4. الاشتراك', 'بعض المحتوى مجاني وبعضه يتطلب اشتراكاً. الاشتراك شخصي وغير قابل للمشاركة.'),
              Divider(height: 22),
              _Term('5. التعديلات', 'قد تُحدَّث هذه الشروط من وقت لآخر، ويُعدّ استمرارك في استخدام التطبيق موافقةً على التعديلات.'),
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
        Text(title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14.5, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
        const SizedBox(height: 6),
        InfoPara(body),
      ],
    );
  }
}
