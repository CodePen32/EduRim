import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/info_widgets.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = <List<String>>[
    ['كيف أشترك في المحتوى المدفوع؟', 'من القائمة الجانبية اختر «اشتراكي»، ثم اختر الخطة الشهرية أو السنوية واتبع خطوات الاشتراك. بعد التفعيل ستتمكن من مشاهدة كل الدروس المدفوعة.'],
    ['هل يمكنني مشاهدة الدروس بدون إنترنت؟', 'نعم. افتح الدرس ثم اضغط «تنزيل للمشاهدة بدون إنترنت». بعد اكتمال التنزيل ستجد الدرس في صفحة «التنزيلات» ويمكن تشغيله بدون اتصال.'],
    ['لماذا لا يعمل فيديو بعض الدروس؟', 'قد يكون الفيديو قيد الرفع أو غير متوفر مؤقتاً. جرّب لاحقاً أو استخدم زر «فتح في المتصفح». إذا استمرت المشكلة تواصل معنا.'],
    ['كيف تصلني الإشعارات؟', 'تظهر الإشعارات داخل التطبيق في صفحة «الإشعارات»، وقد تصلك أيضاً في شريط الهاتف عند إضافة درس جديد لمسارك. تأكد من السماح بالإشعارات.'],
    ['هل يمكنني تغيير رقم الهاتف أو المسار الدراسي؟', 'رقم الهاتف والبريد والمسار الدراسي تُحدَّد عند التسجيل ولا يمكن تغييرها لاحقاً حفاظاً على أمان الحساب. يمكنك تعديل الاسم والمدينة فقط.'],
    ['نسيت أين حفظت درساً نزّلته؟', 'كل الدروس المنزّلة تظهر في صفحة «التنزيلات» من الشريط السفلي.'],
  ];

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      appBarTitle: 'الأسئلة الشائعة',
      children: [
        const InfoHero(icon: Icons.help_rounded, title: 'الأسئلة الشائعة', subtitle: 'إجابات لأكثر الأسئلة تكراراً'),
        const SizedBox(height: 16),
        ..._faqs.map((qa) => Padding(
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
                      textAlign: TextAlign.right,
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
