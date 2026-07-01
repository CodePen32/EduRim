import 'package:flutter/material.dart';
import '../widgets/info_widgets.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      appBarTitle: 'من نحن',
      children: const [
        InfoHero(icon: Icons.school_rounded, title: 'Concouri', subtitle: 'منصة تعليمية موريتانية'),
        SizedBox(height: 18),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoPara('Concouri منصة تعليمية موجّهة لطلاب موريتانيا، تجمع الدروس والتمارين ومواضيع الامتحانات في مكان واحد منظّم وسهل الاستخدام.'),
              SizedBox(height: 12),
              InfoPara('نهدف إلى تسهيل الوصول إلى محتوى تعليمي عالي الجودة لكل المسارات: Concours وBEPC والباكالوريا بشعبها المختلفة، مع إمكانية المشاهدة والتنزيل بدون إنترنت.'),
              SizedBox(height: 12),
              InfoPara('نسعى دائماً لتطوير المنصة وإضافة محتوى جديد، ونرحّب باقتراحاتكم عبر صفحة «اقترح تطوير».'),
            ],
          ),
        ),
        SizedBox(height: 14),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoSectionTitle(icon: Icons.flag_rounded, title: 'رسالتنا'),
              SizedBox(height: 6),
              InfoPara('تعليم متاح للجميع، أينما كانوا.'),
              SizedBox(height: 14),
              InfoSectionTitle(icon: Icons.verified_rounded, title: 'قيمنا'),
              SizedBox(height: 6),
              InfoPara('الجودة، البساطة، الاستمرارية.'),
            ],
          ),
        ),
      ],
    );
  }
}
