import 'locale_controller.dart';

/// طبقة ترجمة بسيطة ومنظمة للنصوص الثابتة (ar / fr).
/// الاستخدام: `tr('nav.home')`.
/// ملاحظة: لا تُترجم بيانات API (أسماء المواد/عناوين الدروس) — تبقى كما هي.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _t = {
    // ── Bottom navigation ──
    'nav.home': {'ar': 'الرئيسية', 'fr': 'Accueil'},
    'nav.favorites': {'ar': 'المفضلة', 'fr': 'Favoris'},
    'nav.downloads': {'ar': 'التنزيلات', 'fr': 'Téléchargements'},
    'nav.calculator': {'ar': 'الحاسبة', 'fr': 'Calculatrice'},
    'nav.account': {'ar': 'حسابي', 'fr': 'Mon compte'},

    // ── Drawer ──
    'drawer.home': {'ar': 'الصفحة الرئيسية', 'fr': 'Accueil'},
    'drawer.subjects': {'ar': 'المواد', 'fr': 'Matières'},
    'drawer.subscription': {'ar': 'اشتراكي', 'fr': 'Mon abonnement'},
    'drawer.notifications': {'ar': 'الإشعارات', 'fr': 'Notifications'},
    'drawer.support': {'ar': 'الدعم والمساعدة', 'fr': 'Aide et support'},
    'drawer.contact': {'ar': 'تواصل معنا', 'fr': 'Contactez-nous'},
    'drawer.contactHistory': {'ar': 'سجل التواصل', 'fr': 'Historique de contact'},
    'drawer.faq': {'ar': 'الأسئلة الشائعة', 'fr': 'FAQ'},
    'drawer.suggest': {'ar': 'اقترح تطوير', 'fr': 'Proposer une idée'},
    'drawer.legal': {'ar': 'معلومات قانونية', 'fr': 'Informations légales'},
    'drawer.about': {'ar': 'من نحن', 'fr': 'À propos'},
    'drawer.terms': {'ar': 'شروط الاستخدام', 'fr': "Conditions d'utilisation"},
    'drawer.language': {'ar': 'تغيير اللغة', 'fr': 'Changer la langue'},
    'drawer.logout': {'ar': 'تسجيل الخروج', 'fr': 'Déconnexion'},
    'logout.confirm': {'ar': 'هل تريد تسجيل الخروج؟', 'fr': 'Voulez-vous vous déconnecter ?'},
    'common.cancel': {'ar': 'إلغاء', 'fr': 'Annuler'},

    // ── Home ──
    'home.searchHint': {'ar': 'ابحث عن درس أو مادة...', 'fr': 'Rechercher un cours ou une matière...'},
    'home.lessons': {'ar': 'الدروس', 'fr': 'Cours'},
    'home.exercises': {'ar': 'التمارين', 'fr': 'Exercices'},
    'home.teachers': {'ar': 'الأساتذة', 'fr': 'Enseignants'},
    'home.mySubjects': {'ar': 'مواد مسارك الدراسي', 'fr': 'Matières de votre parcours'},
    'home.noSubjects': {'ar': 'لا توجد مواد متاحة لهذا المستوى حاليا', 'fr': "Aucune matière disponible pour ce niveau"},
    'home.loadError': {'ar': 'تعذّر تحميل المواد', 'fr': 'Échec du chargement des matières'},
    'home.connError': {'ar': 'تعذر الاتصال بالخادم', 'fr': 'Impossible de se connecter au serveur'},
    'common.retry': {'ar': 'إعادة المحاولة', 'fr': 'Réessayer'},
    'common.saving': {'ar': 'جارٍ الحفظ...', 'fr': 'Enregistrement...'},

    // ── Lessons list ──
    'lessons.allTitle': {'ar': 'جميع الدروس', 'fr': 'Tous les cours'},
    'lessons.subjectTitle': {'ar': 'دروس المادة', 'fr': 'Cours de la matière'},
    'lessons.none': {'ar': 'لا توجد دروس حالياً', 'fr': 'Aucun cours pour le moment'},
    'lessons.watch': {'ar': 'شاهد', 'fr': 'Regarder'},
    'lessons.free': {'ar': 'مجاني', 'fr': 'Gratuit'},
    'lessons.subscribersOnly': {'ar': 'للمشتركين فقط', 'fr': 'Abonnés seulement'},

    // ── Lesson details (main actions) ──
    'details.watchLesson': {'ar': 'مشاهدة الدرس', 'fr': 'Regarder le cours'},
    'details.videoUnavailable': {'ar': 'الفيديو غير متاح حالياً', 'fr': 'Vidéo indisponible'},
    'details.openPdf': {'ar': 'فتح الملخص PDF', 'fr': 'Ouvrir le résumé PDF'},
    'details.downloadOffline': {'ar': 'تنزيل للمشاهدة بدون إنترنت', 'fr': 'Télécharger hors ligne'},
    'details.markCompleted': {'ar': 'تحديد كدرس مكتمل', 'fr': 'Marquer comme terminé'},
    'details.description': {'ar': 'وصف الدرس', 'fr': 'Description du cours'},
    'details.pdfUnavailable': {'ar': 'الملخص غير متاح حالياً', 'fr': 'Résumé indisponible'},
    'details.free': {'ar': 'درس مجاني', 'fr': 'Cours gratuit'},
    'details.subscribersOnly': {'ar': 'للمشتركين فقط', 'fr': 'Abonnés seulement'},

    // ── Language screen ──
    'lang.title': {'ar': 'تغيير اللغة', 'fr': 'Changer la langue'},
    'lang.arabic': {'ar': 'العربية', 'fr': 'Arabe'},
    'lang.french': {'ar': 'الفرنسية', 'fr': 'Français'},
    'lang.changed': {'ar': 'تم تغيير اللغة', 'fr': 'Langue changée'},

    // ── Suggest feature ──
    'suggest.title': {'ar': 'اقترح تطوير', 'fr': 'Proposer une idée'},
    'suggest.heroSubtitle': {'ar': 'رأيك يساعدنا على تحسين المنصة', 'fr': 'Votre avis nous aide à améliorer la plateforme'},
    'suggest.fieldTitle': {'ar': 'عنوان الاقتراح', 'fr': "Titre de la suggestion"},
    'suggest.fieldDesc': {'ar': 'الوصف', 'fr': 'Description'},
    'suggest.submit': {'ar': 'إرسال الاقتراح', 'fr': 'Envoyer la suggestion'},
    'suggest.titleHint': {'ar': 'مثال: إضافة وضع ليلي', 'fr': 'Ex : ajouter un mode sombre'},
    'suggest.descHint': {'ar': 'اشرح فكرتك بالتفصيل...', 'fr': 'Décrivez votre idée en détail...'},
    'suggest.titleShort': {'ar': 'العنوان قصير جداً', 'fr': 'Titre trop court'},
    'suggest.descShort': {'ar': 'الوصف قصير جداً', 'fr': 'Description trop courte'},
    'suggest.sent': {'ar': 'تم إرسال اقتراحك بنجاح', 'fr': 'Votre suggestion a été envoyée avec succès'},
    'suggest.sendFailed': {'ar': 'تعذر إرسال الاقتراح', 'fr': "Échec de l'envoi de la suggestion"},
    'suggest.sendFailedConn': {'ar': 'تعذر إرسال الاقتراح. تحقق من اتصالك وحاول مجدداً.', 'fr': "Échec de l'envoi. Vérifiez votre connexion et réessayez."},
    'suggest.titleMin': {'ar': 'العنوان يجب أن لا يقل عن 3 أحرف', 'fr': 'Le titre doit comporter au moins 3 caractères'},
    'suggest.descMin': {'ar': 'الوصف يجب أن لا يقل عن 10 أحرف', 'fr': 'La description doit comporter au moins 10 caractères'},
    'suggest.receivedTitle': {'ar': 'تم استلام اقتراحك', 'fr': 'Suggestion reçue'},
    'suggest.receivedBody': {'ar': 'شكراً لك! سنأخذ اقتراحك بعين الاعتبار.', 'fr': 'Merci ! Nous prendrons votre suggestion en compte.'},
    'suggest.sending': {'ar': 'جارٍ الإرسال...', 'fr': 'Envoi...'},

    // ── Request subscription ──
    'req.title': {'ar': 'طلب اشتراك جديد', 'fr': "Nouvelle demande d'abonnement"},
    'req.planType': {'ar': 'نوع الاشتراك', 'fr': "Type d'abonnement"},
    'req.phone': {'ar': 'رقم الهاتف *', 'fr': 'Numéro de téléphone *'},
    'req.phoneHint': {'ar': 'أدخل رقم هاتفك', 'fr': 'Saisissez votre numéro'},
    'req.phoneRequired': {'ar': 'رقم الهاتف مطلوب', 'fr': 'Le numéro de téléphone est requis'},
    'req.paymentAccounts': {'ar': 'حسابات الدفع', 'fr': 'Comptes de paiement'},
    'req.paymentInstructions': {'ar': 'تعليمات الدفع', 'fr': 'Instructions de paiement'},
    'req.paymentBody': {'ar': 'يرجى تحويل مبلغ الاشتراك إلى الرقم 36050044 عبر تطبيق الدفع الذي اخترته، ثم إرفاق لقطة شاشة من عملية التحويل.', 'fr': "Veuillez transférer le montant de l'abonnement au 36050044 via l'application de paiement choisie, puis joindre une capture du transfert."},
    'req.copyNumber': {'ar': 'نسخ الرقم', 'fr': 'Copier le numéro'},
    'req.numberCopied': {'ar': 'تم نسخ الرقم', 'fr': 'Numéro copié'},
    'req.receipt': {'ar': 'إيصال التحويل *', 'fr': 'Reçu du transfert *'},
    'req.attachReceipt': {'ar': 'يرجى الضغط لإرفاق صورة الحوالة', 'fr': "Appuyez pour joindre l'image du transfert"},
    'req.receiptUploaded': {'ar': 'تم رفع الصورة بنجاح', 'fr': "Image téléchargée avec succès"},
    'req.uploadFailed': {'ar': 'تعذر رفع الصورة', 'fr': "Échec du téléchargement de l'image"},
    'req.note': {'ar': 'ملاحظة (اختياري)', 'fr': 'Note (facultatif)'},
    'req.noteHint': {'ar': 'أي معلومات إضافية...', 'fr': 'Toute information supplémentaire...'},
    'req.selectPlan': {'ar': 'يرجى اختيار نوع الاشتراك', 'fr': "Veuillez choisir le type d'abonnement"},
    'req.attachReceiptError': {'ar': 'يرجى إرفاق صورة إيصال التحويل', 'fr': "Veuillez joindre l'image du reçu"},
    'req.sent': {'ar': 'تم إرسال طلبك بنجاح، سيتم تفعيل اشتراكك بعد تأكد الإدارة من صحة عملية الدفع.', 'fr': "Votre demande a été envoyée. Votre abonnement sera activé après vérification du paiement par l'administration."},
    'req.noPlans': {'ar': 'لا توجد خطط متاحة حالياً', 'fr': 'Aucun forfait disponible pour le moment'},
    'req.submit': {'ar': 'إتمام الدفع', 'fr': 'Finaliser le paiement'},

    // ── Calculator ──
    'calc.title': {'ar': 'الحاسبة', 'fr': 'Calculatrice'},
    'calc.loadServerError': {'ar': 'تعذر الاتصال بالخادم، تحقق من اتصالك', 'fr': 'Connexion au serveur impossible, vérifiez votre connexion'},
    'calc.loadError': {'ar': 'حدث خطأ أثناء تحميل الحاسبة', 'fr': 'Erreur lors du chargement de la calculatrice'},
    'calc.parseError': {'ar': 'خطأ في تحليل البيانات — تواصل مع الدعم', 'fr': 'Erreur de traitement des données — contactez le support'},
    'calc.invalidValue': {'ar': 'قيمة غير صالحة', 'fr': 'Valeur invalide'},
    'calc.negative': {'ar': 'لا يمكن أن تكون سالبة', 'fr': 'Ne peut pas être négatif'},
    'calc.maxMark': {'ar': 'الحد الأقصى %s', 'fr': 'Maximum %s'},
    'calc.enterMark': {'ar': 'أدخل النقطة', 'fr': 'Saisissez la note'},
    'calc.retry': {'ar': 'إعادة المحاولة', 'fr': 'Réessayer'},
    'calc.noSubjects': {'ar': 'لا توجد مواد للحاسبة لهذا المستوى حالياً', 'fr': 'Aucune matière disponible pour ce niveau'},
    'calc.enterMarks': {'ar': 'أدخل نقاطك', 'fr': 'Saisissez vos notes'},
    'calc.clearMarks': {'ar': 'مسح النقاط', 'fr': 'Effacer les notes'},
    'calc.pointsHint': {'ar': 'أدخل نقاطك · حد النجاح 85 / 200', 'fr': 'Saisissez vos points · seuil de réussite 85 / 200'},
    'calc.bepcHint': {'ar': 'راسب < 7 · متجاوز 7–8.5 · ناجح ≥ 8.5', 'fr': 'Échec < 7 · rattrapage 7–8.5 · admis ≥ 8.5'},
    'calc.bacHint': {'ar': 'راسب < 8 · استدراك 8–10 · ناجح ≥ 10', 'fr': 'Échec < 8 · rattrapage 8–10 · admis ≥ 10'},
    'calc.sysConcours': {'ar': 'نظام كونكور — النقاط / 200', 'fr': 'Système Concours — points / 200'},
    'calc.sysBepc': {'ar': 'نظام BEPC — المعدل / 20', 'fr': 'Système BEPC — moyenne / 20'},
    'calc.sysBac': {'ar': 'نظام BAC — المعدل / 20', 'fr': 'Système BAC — moyenne / 20'},
    'calc.required': {'ar': 'إجباري', 'fr': 'Obligatoire'},
    'calc.coefPrefix': {'ar': 'م %s', 'fr': 'coef %s'},
    'calc.yourTotal': {'ar': 'مجموع نقاطك', 'fr': 'Total de vos points'},
    'calc.yourAverage': {'ar': 'معدلك', 'fr': 'Votre moyenne'},
    'calc.maxTotal': {'ar': 'المجموع الكلي: %s نقطة', 'fr': 'Total maximum : %s points'},
    'calc.sumCoef': {'ar': 'مجموع المعاملات: %s', 'fr': 'Somme des coefficients : %s'},
    'calc.calculating': {'ar': 'جارٍ الحساب...', 'fr': 'Calcul...'},
    'calc.calculate': {'ar': 'احسب النتيجة', 'fr': 'Calculer le résultat'},

    // ── My subscription ──
    'mysub.title': {'ar': 'اشتراكي', 'fr': 'Mon abonnement'},
    'mysub.expiringSoon': {'ar': 'اشتراكك سينتهي قريبًا، يرجى تجديده للاستمرار في الوصول إلى الدروس.', 'fr': 'Votre abonnement expire bientôt, renouvelez-le pour continuer à accéder aux cours.'},
    'mysub.activeBadge': {'ar': 'نشط', 'fr': 'Actif'},
    'mysub.remaining': {'ar': 'تبقى', 'fr': 'Restant'},
    'mysub.daysUnit': {'ar': '%s يوم', 'fr': '%s jour(s)'},
    'mysub.details': {'ar': 'تفاصيل الاشتراك', 'fr': "Détails de l'abonnement"},
    'mysub.startDate': {'ar': 'تاريخ البداية', 'fr': 'Date de début'},
    'mysub.endDate': {'ar': 'تاريخ الانتهاء', 'fr': "Date d'expiration"},
    'mysub.daysRemaining': {'ar': 'الأيام المتبقية', 'fr': 'Jours restants'},
    'mysub.renew': {'ar': 'طلب تجديد الاشتراك', 'fr': "Demander le renouvellement"},
    'mysub.pending': {'ar': 'طلبك قيد المراجعة', 'fr': 'Votre demande est en cours de traitement'},
    'mysub.plan': {'ar': 'الخطة: %s', 'fr': 'Forfait : %s'},
    'mysub.pendingBody': {'ar': 'تم إرسال الطلب وسيتم مراجعته من قِبَل الإدارة قريباً.', 'fr': "La demande a été envoyée et sera examinée par l'administration prochainement."},
    'mysub.rejected': {'ar': 'تم رفض طلبك السابق', 'fr': 'Votre demande précédente a été refusée'},
    'mysub.rejectReason': {'ar': 'سبب الرفض: %s', 'fr': 'Motif du refus : %s'},
    'mysub.newRequest': {'ar': 'إرسال طلب جديد', 'fr': 'Envoyer une nouvelle demande'},
    'mysub.noActive': {'ar': 'لا يوجد اشتراك نشط', 'fr': "Aucun abonnement actif"},
    'mysub.noActiveBody': {'ar': 'للوصول إلى جميع الدروس والمحتوى المدفوع،\nقدّم طلب اشتراك وسيتم مراجعته.', 'fr': "Pour accéder à tous les cours et au contenu payant,\nsoumettez une demande d'abonnement."},
    'mysub.request': {'ar': 'طلب اشتراك', 'fr': "Demander un abonnement"},

    // ── Teachers ──
    'teachers.title': {'ar': 'الأساتذة', 'fr': 'Enseignants'},
    'teachers.none': {'ar': 'لا يوجد أساتذة لهذه المادة', 'fr': 'Aucun enseignant pour cette matière'},

    // ── Announcement ──
    'ann.tapMore': {'ar': 'اضغط للمزيد', 'fr': 'Appuyez pour en savoir plus'},

    // ── Past exams ──
    'exams.title': {'ar': 'مواضيع الامتحانات السابقة', 'fr': "Sujets d'examens précédents"},
    'exams.none': {'ar': 'لا توجد مواضيع امتحانات حالياً', 'fr': "Aucun sujet d'examen pour le moment"},
    'exams.viewTopic': {'ar': 'عرض الموضوع', 'fr': 'Voir le sujet'},
    'exams.viewSolution': {'ar': 'عرض الحل', 'fr': 'Voir le corrigé'},
    'exams.filesUnavailable': {'ar': 'الملفات غير متاحة حالياً', 'fr': 'Fichiers indisponibles'},

    // ── Progress ──
    'progress.title': {'ar': 'تقدمي الدراسي', 'fr': 'Ma progression'},
    'progress.completedLessons': {'ar': 'الدروس المكتملة', 'fr': 'Cours terminés'},
    'progress.avg': {'ar': 'متوسط التقدم', 'fr': 'Progression moyenne'},
    'progress.lastLesson': {'ar': 'آخر درس', 'fr': 'Dernier cours'},
    'progress.bySubject': {'ar': 'التقدم حسب المادة', 'fr': 'Progression par matière'},
    'progress.noData': {'ar': 'لا توجد بيانات تقدم بعد', 'fr': 'Aucune donnée de progression'},

    // ── PDF viewer ──
    'pdf.title': {'ar': 'الملخص', 'fr': 'Résumé'},
    'pdf.unavailable': {'ar': 'الملخص غير متاح حالياً', 'fr': 'Résumé indisponible'},
    'pdf.loadErrorCode': {'ar': 'تعذر تحميل الملخص (رمز: %s)', 'fr': 'Échec du chargement du résumé (code : %s)'},
    'pdf.empty': {'ar': 'ملف PDF فارغ أو غير صالح', 'fr': 'Fichier PDF vide ou invalide'},
    'pdf.fetchError': {'ar': 'تعذر جلب الملخص: %s', 'fr': 'Échec de récupération du résumé : %s'},
    'pdf.loading': {'ar': 'جاري تحميل الملخص...', 'fr': 'Chargement du résumé...'},
    'pdf.openBrowser': {'ar': 'فتح في المتصفح', 'fr': 'Ouvrir dans le navigateur'},

    // ── Search ──
    'search.title': {'ar': 'البحث', 'fr': 'Recherche'},
    'search.hint': {'ar': 'ابحث عن درس، مادة، أستاذ...', 'fr': 'Rechercher un cours, une matière, un enseignant...'},
    'search.error': {'ar': 'تعذر إجراء البحث', 'fr': 'Échec de la recherche'},
    'search.start': {'ar': 'ابدأ البحث للعثور على المحتوى', 'fr': 'Lancez une recherche pour trouver du contenu'},
    'search.noResults': {'ar': 'لا توجد نتائج', 'fr': 'Aucun résultat'},
    'search.subject': {'ar': 'مادة', 'fr': 'Matière'},
    'search.lesson': {'ar': 'درس', 'fr': 'Cours'},
    'search.exercise': {'ar': 'تمرين', 'fr': 'Exercice'},
    'search.teacher': {'ar': 'أستاذ', 'fr': 'Enseignant'},

    // ── Exercises ──
    'exercises.title': {'ar': 'التمارين', 'fr': 'Exercices'},
    'exercises.none': {'ar': 'لا توجد تمارين حالياً', 'fr': 'Aucun exercice pour le moment'},
    'exercises.watchSolution': {'ar': 'شاهد شرح الحل بالفيديو', 'fr': "Regarder la correction en vidéo"},
    'exercises.solutionUnavailable': {'ar': 'شرح الفيديو غير متاح حالياً', 'fr': 'Correction vidéo indisponible'},
    'exercises.subjectTitle': {'ar': 'تمارين المادة', 'fr': 'Exercices de la matière'},
    'exercises.allTitle': {'ar': 'التمارين والاختبارات', 'fr': 'Exercices et tests'},
    'exercises.year': {'ar': 'سنة %s', 'fr': 'Année %s'},
    'diff.easy': {'ar': 'سهل', 'fr': 'Facile'},
    'diff.medium': {'ar': 'متوسط', 'fr': 'Moyen'},
    'diff.hard': {'ar': 'صعب', 'fr': 'Difficile'},

    // ── Exercise details ──
    'exDet.title': {'ar': 'تفاصيل التمرين', 'fr': "Détails de l'exercice"},
    'exDet.addedFav': {'ar': 'تمت الإضافة إلى المفضلة ❤️', 'fr': 'Ajouté aux favoris ❤️'},
    'exDet.alreadyFav': {'ar': 'التمرين موجود في المفضلة بالفعل', 'fr': "L'exercice est déjà dans les favoris"},
    'exDet.addFailed': {'ar': 'تعذر الإضافة', 'fr': "Échec de l'ajout"},
    'exDet.savedDownloads': {'ar': 'تم حفظ التمرين في قائمة التنزيلات', 'fr': 'Exercice enregistré dans les téléchargements'},
    'exDet.alreadySaved': {'ar': 'التمرين محفوظ بالفعل', 'fr': "L'exercice est déjà enregistré"},
    'exDet.saveFailed': {'ar': 'تعذر الحفظ', 'fr': "Échec de l'enregistrement"},
    'exDet.resources': {'ar': 'موارد التمرين', 'fr': "Ressources de l'exercice"},
    'exDet.file': {'ar': 'ملف التمرين', 'fr': "Fichier de l'exercice"},
    'exDet.fileTap': {'ar': 'اضغط لعرض التمرين', 'fr': "Appuyez pour afficher l'exercice"},
    'exDet.fileUnavailable': {'ar': 'ملف التمرين غير متاح حالياً', 'fr': "Fichier de l'exercice indisponible"},
    'exDet.solution': {'ar': 'الحل النموذجي', 'fr': 'Corrigé type'},
    'exDet.solutionTap': {'ar': 'اضغط لعرض الحل', 'fr': 'Appuyez pour afficher le corrigé'},
    'exDet.solutionUnavailable': {'ar': 'الحل غير متاح حالياً', 'fr': 'Corrigé indisponible'},
    'exDet.videoSolution': {'ar': 'فيديو الحل', 'fr': 'Vidéo du corrigé'},
    'exDet.videoTap': {'ar': 'شاهد شرح الحل بالفيديو', 'fr': 'Regarder la correction en vidéo'},
    'exDet.videoUnavailable': {'ar': 'شرح الفيديو غير متاح حالياً', 'fr': 'Correction vidéo indisponible'},
    'exDet.openFile': {'ar': 'فتح ملف التمرين', 'fr': "Ouvrir le fichier de l'exercice"},
    'exDet.inFav': {'ar': 'في المفضلة', 'fr': 'Dans les favoris'},
    'exDet.addFav': {'ar': 'إضافة للمفضلة', 'fr': 'Ajouter aux favoris'},
    'exDet.saved': {'ar': 'محفوظ', 'fr': 'Enregistré'},
    'exDet.save': {'ar': 'حفظ التمرين', 'fr': "Enregistrer l'exercice"},

    // ── Subject details ──
    'subject.lessons': {'ar': 'الدروس', 'fr': 'Cours'},
    'subject.exercises': {'ar': 'التمارين', 'fr': 'Exercices'},
    'subject.noLessons': {'ar': 'لا توجد دروس لهذه المادة حالياً', 'fr': 'Aucun cours pour cette matière'},
    'subject.fallback': {'ar': 'المادة', 'fr': 'Matière'},
    'subject.teachers': {'ar': 'الأساتذة', 'fr': 'Enseignants'},
    'subject.allLessons': {'ar': 'كل الدروس', 'fr': 'Tous les cours'},
    'subject.pastExams': {'ar': 'الامتحانات السابقة', 'fr': 'Examens précédents'},
    'subject.availableLessons': {'ar': 'الدروس المتاحة', 'fr': 'Cours disponibles'},
    'subject.reload': {'ar': 'إعادة التحميل', 'fr': 'Recharger'},
    'subject.examTopics': {'ar': 'مواضيع الامتحانات', 'fr': "Sujets d'examens"},

    // ── About Us ──
    'about.title': {'ar': 'من نحن', 'fr': 'À propos'},
    'about.heroSubtitle': {'ar': 'منصة تعليمية موريتانية', 'fr': 'Plateforme éducative mauritanienne'},
    'about.p1': {'ar': 'Concouri منصة تعليمية موجّهة لطلاب موريتانيا، تجمع الدروس والتمارين ومواضيع الامتحانات في مكان واحد منظّم وسهل الاستخدام.', 'fr': "Concouri est une plateforme éducative destinée aux élèves de Mauritanie, réunissant cours, exercices et sujets d'examens en un seul endroit organisé et simple."},
    'about.p2': {'ar': 'نهدف إلى تسهيل الوصول إلى محتوى تعليمي عالي الجودة لكل المسارات: Concours وBEPC والباكالوريا بشعبها المختلفة، مع إمكانية المشاهدة والتنزيل بدون إنترنت.', 'fr': "Nous facilitons l'accès à un contenu de qualité pour tous les parcours : Concours, BEPC et Baccalauréat, avec visionnage et téléchargement hors ligne."},
    'about.p3': {'ar': 'نسعى دائماً لتطوير المنصة وإضافة محتوى جديد، ونرحّب باقتراحاتكم عبر صفحة «اقترح تطوير».', 'fr': "Nous améliorons constamment la plateforme et accueillons vos suggestions via « Proposer une idée »."},
    'about.mission': {'ar': 'رسالتنا', 'fr': 'Notre mission'},
    'about.missionBody': {'ar': 'تعليم متاح للجميع، أينما كانوا.', 'fr': 'Une éducation accessible à tous, partout.'},
    'about.values': {'ar': 'قيمنا', 'fr': 'Nos valeurs'},
    'about.valuesBody': {'ar': 'الجودة، البساطة، الاستمرارية.', 'fr': 'Qualité, simplicité, continuité.'},

    // ── Terms ──
    'terms.title': {'ar': 'شروط الاستخدام', 'fr': "Conditions d'utilisation"},
    'terms.heroSubtitle': {'ar': 'يرجى قراءتها قبل استخدام التطبيق', 'fr': "Veuillez les lire avant d'utiliser l'application"},
    'terms.t1title': {'ar': '1. الاستخدام الشخصي', 'fr': '1. Usage personnel'},
    'terms.t1body': {'ar': 'يُستخدم التطبيق لأغراض تعليمية شخصية فقط. لا يجوز إعادة بيع أو توزيع المحتوى دون إذن.', 'fr': "L'application est destinée à un usage éducatif personnel. La revente ou la distribution du contenu sans autorisation est interdite."},
    'terms.t2title': {'ar': '2. الحساب', 'fr': '2. Compte'},
    'terms.t2body': {'ar': 'أنت مسؤول عن سرية بيانات حسابك. رقم الهاتف والبريد يُحدّدان عند التسجيل ولا يمكن تغييرهما لاحقاً من التطبيق.', 'fr': "Vous êtes responsable de la confidentialité de votre compte. Le téléphone et l'e-mail sont définis à l'inscription et non modifiables."},
    'terms.t3title': {'ar': '3. المحتوى', 'fr': '3. Contenu'},
    'terms.t3body': {'ar': 'كل الدروس والتمارين والمواضيع مملوكة للمنصة أو لأصحابها. يُمنع نسخها أو نشرها خارج التطبيق.', 'fr': "Tous les cours, exercices et sujets appartiennent à la plateforme ou à leurs auteurs. Leur copie ou diffusion hors de l'application est interdite."},
    'terms.t4title': {'ar': '4. الاشتراك', 'fr': '4. Abonnement'},
    'terms.t4body': {'ar': 'بعض المحتوى مجاني وبعضه يتطلب اشتراكاً. الاشتراك شخصي وغير قابل للمشاركة.', 'fr': "Une partie du contenu est gratuite, une autre nécessite un abonnement. L'abonnement est personnel et non partageable."},
    'terms.t5title': {'ar': '5. التعديلات', 'fr': '5. Modifications'},
    'terms.t5body': {'ar': 'قد تُحدَّث هذه الشروط من وقت لآخر، ويُعدّ استمرارك في استخدام التطبيق موافقةً على التعديلات.', 'fr': "Ces conditions peuvent être mises à jour ; votre utilisation continue vaut acceptation des modifications."},

    // ── Contact history ──
    'contact.title': {'ar': 'سجل التواصل', 'fr': 'Historique de contact'},
    'contact.heroSubtitle': {'ar': 'رسائلك ومحادثاتك مع الدعم', 'fr': 'Vos messages et échanges avec le support'},
    'contact.empty': {'ar': 'لا توجد رسائل بعد', 'fr': 'Aucun message pour le moment'},
    'contact.emptyBody': {'ar': 'سيظهر هنا سجلّ رسائلك ومحادثاتك مع فريق الدعم لاحقاً. للتواصل الآن استخدم زر «تواصل معنا».', 'fr': "L'historique de vos échanges avec le support apparaîtra ici. Pour nous contacter, utilisez « Contactez-nous »."},

    // ── FAQ ──
    'faq.title': {'ar': 'الأسئلة الشائعة', 'fr': 'FAQ'},
    'faq.heroSubtitle': {'ar': 'إجابات لأكثر الأسئلة تكراراً', 'fr': 'Réponses aux questions fréquentes'},
    'faq.q1': {'ar': 'كيف أشترك في المحتوى المدفوع؟', 'fr': "Comment m'abonner au contenu payant ?"},
    'faq.a1': {'ar': 'من القائمة الجانبية اختر «اشتراكي»، ثم اختر الخطة الشهرية أو السنوية واتبع خطوات الاشتراك. بعد التفعيل ستتمكن من مشاهدة كل الدروس المدفوعة.', 'fr': "Dans le menu, choisissez « Mon abonnement », sélectionnez le forfait mensuel ou annuel et suivez les étapes. Une fois activé, vous accédez à tous les cours payants."},
    'faq.q2': {'ar': 'هل يمكنني مشاهدة الدروس بدون إنترنت؟', 'fr': 'Puis-je regarder les cours hors ligne ?'},
    'faq.a2': {'ar': 'نعم. افتح الدرس ثم اضغط «تنزيل للمشاهدة بدون إنترنت». بعد اكتمال التنزيل ستجد الدرس في صفحة «التنزيلات» ويمكن تشغيله بدون اتصال.', 'fr': "Oui. Ouvrez le cours puis appuyez sur « Télécharger hors ligne ». Une fois terminé, le cours apparaît dans « Téléchargements » et se lit sans connexion."},
    'faq.q3': {'ar': 'لماذا لا يعمل فيديو بعض الدروس؟', 'fr': 'Pourquoi la vidéo de certains cours ne fonctionne pas ?'},
    'faq.a3': {'ar': 'قد يكون الفيديو قيد الرفع أو غير متوفر مؤقتاً. جرّب لاحقاً أو استخدم زر «فتح في المتصفح». إذا استمرت المشكلة تواصل معنا.', 'fr': "La vidéo est peut-être en cours de téléversement ou temporairement indisponible. Réessayez plus tard ou utilisez « Ouvrir dans le navigateur ». Si le problème persiste, contactez-nous."},
    'faq.q4': {'ar': 'كيف تصلني الإشعارات؟', 'fr': 'Comment reçois-je les notifications ?'},
    'faq.a4': {'ar': 'تظهر الإشعارات داخل التطبيق في صفحة «الإشعارات»، وقد تصلك أيضاً في شريط الهاتف عند إضافة درس جديد لمسارك. تأكد من السماح بالإشعارات.', 'fr': "Les notifications apparaissent dans la page « Notifications » et peuvent aussi s'afficher dans la barre du téléphone lors de l'ajout d'un cours. Autorisez les notifications."},
    'faq.q5': {'ar': 'هل يمكنني تغيير رقم الهاتف أو المسار الدراسي؟', 'fr': 'Puis-je changer mon téléphone ou mon parcours ?'},
    'faq.a5': {'ar': 'رقم الهاتف والبريد والمسار الدراسي تُحدَّد عند التسجيل ولا يمكن تغييرها لاحقاً حفاظاً على أمان الحساب. يمكنك تعديل الاسم والمدينة فقط.', 'fr': "Le téléphone, l'e-mail et le parcours sont définis à l'inscription et non modifiables pour la sécurité du compte. Vous pouvez modifier le nom et la ville."},
    'faq.q6': {'ar': 'نسيت أين حفظت درساً نزّلته؟', 'fr': "J'ai oublié où se trouve un cours téléchargé ?"},
    'faq.a6': {'ar': 'كل الدروس المنزّلة تظهر في صفحة «التنزيلات» من الشريط السفلي.', 'fr': "Tous les cours téléchargés se trouvent dans « Téléchargements » depuis la barre inférieure."},

    // ── Common ──
    'common.error': {'ar': 'حدث خطأ', 'fr': 'Une erreur est survenue'},
    'common.serverError': {'ar': 'تعذر الاتصال بالخادم، تحقق من الإنترنت', 'fr': 'Connexion au serveur impossible, vérifiez Internet'},
    'common.noTitle': {'ar': '(بدون عنوان)', 'fr': '(Sans titre)'},
    'common.delete': {'ar': 'حذف', 'fr': 'Supprimer'},
    'common.deleteFailed': {'ar': 'تعذر الحذف', 'fr': 'Échec de la suppression'},

    // ── Login ──
    'login.welcome': {'ar': 'مرحباً بك في Concouri', 'fr': 'Bienvenue sur Concouri'},
    'login.subtitle': {'ar': 'سجل دخولك للمتابعة', 'fr': 'Connectez-vous pour continuer'},
    'login.identifier': {'ar': 'البريد الإلكتروني أو رقم الهاتف', 'fr': 'E-mail ou numéro de téléphone'},
    'login.identifierRequired': {'ar': 'أدخل البريد الإلكتروني أو رقم الهاتف', 'fr': "Saisissez l'e-mail ou le téléphone"},
    'login.password': {'ar': 'كلمة المرور', 'fr': 'Mot de passe'},
    'login.passwordShort': {'ar': 'كلمة المرور قصيرة جداً', 'fr': 'Mot de passe trop court'},
    'login.submit': {'ar': 'تسجيل الدخول', 'fr': 'Se connecter'},
    'login.noAccount': {'ar': 'ليس لديك حساب؟', 'fr': "Pas de compte ?"},
    'login.createAccount': {'ar': 'إنشاء حساب', 'fr': 'Créer un compte'},

    // ── Favorites ──
    'fav.title': {'ar': 'المفضلة', 'fr': 'Favoris'},
    'fav.loadError': {'ar': 'تعذر تحميل المفضلة', 'fr': 'Échec du chargement des favoris'},
    'fav.empty': {'ar': 'لا توجد عناصر في المفضلة', 'fr': 'Aucun élément dans les favoris'},
    'fav.browseLessons': {'ar': 'تصفح الدروس', 'fr': 'Parcourir les cours'},
    'fav.remove': {'ar': 'إزالة من المفضلة', 'fr': 'Retirer des favoris'},
    'fav.lesson': {'ar': 'درس', 'fr': 'Cours'},
    'fav.exercise': {'ar': 'تمرين', 'fr': 'Exercice'},

    // ── Notifications ──
    'notif.title': {'ar': 'الإشعارات', 'fr': 'Notifications'},
    'notif.empty': {'ar': 'لا توجد إشعارات', 'fr': 'Aucune notification'},
    'notif.loadError': {'ar': 'تعذر تحميل الإشعارات', 'fr': 'Échec du chargement des notifications'},

    // ── Downloads ──
    'downloads.title': {'ar': 'التنزيلات', 'fr': 'Téléchargements'},
    'downloads.watch': {'ar': 'مشاهدة', 'fr': 'Regarder'},
    'downloads.summary': {'ar': 'الملخص', 'fr': 'Résumé'},
    'downloads.deleteDevice': {'ar': 'حذف من الجهاز', 'fr': "Supprimer de l'appareil"},
    'downloads.videoMissing': {'ar': 'الفيديو غير موجود محلياً', 'fr': 'Vidéo introuvable localement'},
    'downloads.summaryMissing': {'ar': 'الملخص غير موجود محلياً', 'fr': 'Résumé introuvable localement'},
    'downloads.emptyTitle': {'ar': 'لا توجد دروس محملة بعد', 'fr': 'Aucun cours téléchargé pour le moment'},
    'downloads.emptyHint': {'ar': 'افتح أي درس واضغط "تنزيل للمشاهدة بدون إنترنت"', 'fr': 'Ouvrez un cours et appuyez sur « Télécharger hors ligne »'},
    'downloads.webTitle': {'ar': 'التنزيل بدون إنترنت', 'fr': 'Téléchargement hors ligne'},
    'downloads.webBody': {'ar': 'تنزيل الدروس للمشاهدة بدون إنترنت متاح في تطبيق الهاتف فقط.\nعلى الويب يمكنك مشاهدة الدروس وفتح الملخصات مباشرة من صفحة الدرس.', 'fr': "Le téléchargement hors ligne n'est disponible que dans l'application mobile.\nSur le web, vous pouvez regarder les cours et ouvrir les résumés directement depuis la page du cours."},
    'summaryPrefix': {'ar': 'ملخص: ', 'fr': 'Résumé : '},

    // ── Onboarding: learning path / bac branch ──
    'path.title': {'ar': 'اختر مسارك الدراسي', 'fr': 'Choisissez votre parcours'},
    'path.subtitle': {'ar': 'سيتم تخصيص المحتوى والمواد حسب اختيارك', 'fr': 'Le contenu sera personnalisé selon votre choix'},
    'common.continue': {'ar': 'متابعة', 'fr': 'Continuer'},
    'branch.appbar': {'ar': 'اختر شعبة الباكالوريا', 'fr': 'Filière du Baccalauréat'},
    'branch.title': {'ar': 'اختر شعبتك', 'fr': 'Choisissez votre filière'},
    'branch.subtitle': {'ar': 'سيتم عرض المواد والمحتوى المناسب لشعبتك فقط', 'fr': 'Seuls les contenus adaptés à votre filière seront affichés'},
    'branch.start': {'ar': 'ابدأ التعلم', 'fr': "Commencer l'apprentissage"},

    // ── Video player ──
    'video.title': {'ar': 'مشاهدة الدرس', 'fr': 'Regarder le cours'},
    'video.unavailable': {'ar': 'الفيديو غير متاح حالياً', 'fr': 'Vidéo indisponible'},
    'video.playError': {'ar': 'تعذر تشغيل الفيديو. قد يكون الملف غير متوفر أو الرابط غير صالح.', 'fr': "Impossible de lire la vidéo. Le fichier est peut-être indisponible ou le lien invalide."},
    'video.loading': {'ar': 'جاري تحميل الفيديو...', 'fr': 'Chargement de la vidéo...'},
    'video.openBrowser': {'ar': 'فتح في المتصفح', 'fr': 'Ouvrir dans le navigateur'},
    'video.marked': {'ar': 'تم تحديد الدرس كمكتمل', 'fr': 'Cours marqué comme terminé'},

    // ── Profile ──
    'profile.title': {'ar': 'حسابي', 'fr': 'Mon compte'},
    'profile.edit': {'ar': 'تعديل الملف الشخصي', 'fr': 'Modifier le profil'},
    'profile.save': {'ar': 'حفظ', 'fr': 'Enregistrer'},
    'profile.loadError': {'ar': 'تعذر تحميل البيانات', 'fr': 'Échec du chargement des données'},
    'profile.completedLessons': {'ar': 'دروس مكتملة', 'fr': 'Cours terminés'},
    'profile.avgProgress': {'ar': 'متوسط التقدم', 'fr': 'Progression moyenne'},
    'profile.viewProgress': {'ar': 'عرض تقدمي', 'fr': 'Voir ma progression'},
    'profile.calculator': {'ar': 'حاسبة المعدل', 'fr': 'Calculatrice de moyenne'},
    'profile.help': {'ar': 'المساعدة', 'fr': 'Aide'},
    'profile.logoutShort': {'ar': 'خروج', 'fr': 'Quitter'},
    'sub.subscribed': {'ar': 'مشترك', 'fr': 'Abonné'},
    'sub.notSubscribed': {'ar': 'متفرّج (غير مشترك)', 'fr': 'Visiteur (non abonné)'},
    'sub.active': {'ar': 'اشتراك نشط', 'fr': 'Abonnement actif'},
    'sub.daysLeft': {'ar': 'متبقٍ %s يوم', 'fr': 'Reste %s jour(s)'},
    'sub.endsOn': {'ar': 'ينتهي %s', 'fr': 'Expire le %s'},
    'sub.cta': {'ar': 'اشترك للوصول لكامل الدروس والمحتوى', 'fr': "Abonnez-vous pour accéder à tous les cours"},

    // ── Register ──
    'reg.title': {'ar': 'إنشاء حساب', 'fr': 'Créer un compte'},
    'reg.welcome': {'ar': 'مرحباً بك في Concouri', 'fr': 'Bienvenue sur Concouri'},
    'reg.subtitle': {'ar': 'أنشئ حسابك للوصول إلى الدروس والتمارين', 'fr': 'Créez votre compte pour accéder aux cours et exercices'},
    'reg.personalInfo': {'ar': 'المعلومات الشخصية', 'fr': 'Informations personnelles'},
    'reg.fullName': {'ar': 'الاسم الكامل', 'fr': 'Nom complet'},
    'reg.fullNameRequired': {'ar': 'أدخل اسمك الكامل', 'fr': 'Saisissez votre nom complet'},
    'reg.email': {'ar': 'البريد الإلكتروني', 'fr': 'E-mail'},
    'reg.emailRequired': {'ar': 'أدخل البريد الإلكتروني', 'fr': "Saisissez l'e-mail"},
    'reg.emailInvalid': {'ar': 'بريد إلكتروني غير صحيح', 'fr': 'E-mail invalide'},
    'reg.phone': {'ar': 'رقم الهاتف', 'fr': 'Numéro de téléphone'},
    'reg.phoneRequired': {'ar': 'أدخل رقم الهاتف', 'fr': 'Saisissez le numéro de téléphone'},
    'reg.gender': {'ar': 'الجنس', 'fr': 'Sexe'},
    'reg.male': {'ar': 'ذكر', 'fr': 'Homme'},
    'reg.female': {'ar': 'أنثى', 'fr': 'Femme'},
    'reg.passwordSection': {'ar': 'كلمة المرور', 'fr': 'Mot de passe'},
    'reg.password': {'ar': 'كلمة المرور', 'fr': 'Mot de passe'},
    'reg.passwordShort': {'ar': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل', 'fr': 'Le mot de passe doit contenir au moins 6 caractères'},
    'reg.passwordConfirm': {'ar': 'تأكيد كلمة المرور', 'fr': 'Confirmer le mot de passe'},
    'reg.passwordConfirmRequired': {'ar': 'أكد كلمة المرور', 'fr': 'Confirmez le mot de passe'},
    'reg.passwordMismatch': {'ar': 'كلمتا المرور غير متطابقتين', 'fr': 'Les mots de passe ne correspondent pas'},
    'reg.submit': {'ar': 'إنشاء الحساب', 'fr': 'Créer le compte'},
    'reg.haveAccount': {'ar': 'لديك حساب بالفعل؟', 'fr': 'Vous avez déjà un compte ?'},

    // ── Edit profile ──
    'edit.fullName': {'ar': 'الاسم الكامل', 'fr': 'Nom complet'},
    'edit.email': {'ar': 'البريد الإلكتروني', 'fr': 'E-mail'},
    'edit.city': {'ar': 'المدينة', 'fr': 'Ville'},
    'edit.phone': {'ar': 'رقم الهاتف', 'fr': 'Numéro de téléphone'},
    'edit.level': {'ar': 'المستوى الدراسي', 'fr': 'Niveau scolaire'},
    'edit.notSet': {'ar': 'غير محدد', 'fr': 'Non défini'},
    'edit.unknown': {'ar': 'غير معروف', 'fr': 'Inconnu'},
    'edit.save': {'ar': 'حفظ التغييرات', 'fr': 'Enregistrer les modifications'},
    'edit.saved': {'ar': 'تم حفظ التغييرات بنجاح', 'fr': 'Modifications enregistrées'},
    'edit.saveFailed': {'ar': 'تعذر حفظ التغييرات', 'fr': "Échec de l'enregistrement"},
  };

  /// استبدال بسيط لعنصر %s في النص المترجم.
  static String withArg(String key, String value) =>
      get(key).replaceFirst('%s', value);

  /// ترجمة قيمة الصعوبة القادمة من API (سهل/متوسط/صعب) للعرض فقط.
  static String difficulty(String raw) {
    switch (raw) {
      case 'سهل': return get('diff.easy');
      case 'متوسط': return get('diff.medium');
      case 'صعب': return get('diff.hard');
      default: return raw;
    }
  }

  static String get _lang => localeController.locale.value.languageCode;

  static String get(String key) {
    final entry = _t[key];
    if (entry == null) return key;
    return entry[_lang] ?? entry['ar'] ?? key;
  }
}

/// اختصار عام للترجمة.
String tr(String key) => AppStrings.get(key);
