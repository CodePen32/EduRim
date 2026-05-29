import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/learning_paths/screens/select_learning_path_screen.dart';
import '../../features/learning_paths/screens/select_bac_branch_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/subjects/screens/subject_details_screen.dart';
import '../../features/subjects/screens/subjects_screen.dart';
import '../../features/teachers/screens/teachers_screen.dart';
import '../../features/lessons/screens/lessons_list_screen.dart';
import '../../features/lessons/screens/lesson_details_screen.dart';
import '../../features/lessons/screens/video_player_screen.dart';
import '../../features/lessons/screens/pdf_viewer_screen.dart';
import '../../features/exercises/screens/exercises_list_screen.dart';
import '../../features/exercises/screens/exercise_details_screen.dart';
import '../../features/downloads/screens/downloads_screen.dart';
import '../../features/favorites/screens/favorites_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/calculator/screens/average_calculator_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/past_exams/screens/past_exams_screen.dart';
import '../../features/subscription/screens/my_subscription_screen.dart';
import '../../features/subscription/screens/request_subscription_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String selectLearningPath = '/select-learning-path';
  static const String selectBacBranch = '/select-bac-branch';
  static const String home = '/home';
  static const String subjectDetails = '/subject-details';
  static const String teachers = '/teachers';
  static const String lessonsList = '/lessons-list';
  static const String lessonDetails = '/lesson-details';
  static const String videoPlayer = '/video-player';
  static const String pdfViewer = '/pdf-viewer';
  static const String exercisesList = '/exercises-list';
  static const String exerciseDetails = '/exercise-details';
  static const String downloads = '/downloads';
  static const String favorites = '/favorites';
  static const String notifications = '/notifications';
  static const String averageCalculator = '/average-calculator';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String search = '/search';
  static const String progress = '/progress';
  static const String pastExams = '/past-exams';
  static const String subjects = '/subjects';
  static const String mySubscription = '/my-subscription';
  static const String requestSubscription = '/request-subscription';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    selectLearningPath: (_) => const SelectLearningPathScreen(),
    selectBacBranch: (_) => const SelectBacBranchScreen(),
    home: (_) => const HomeScreen(),
    subjectDetails: (_) => const SubjectDetailsScreen(),
    teachers: (_) => const TeachersScreen(),
    lessonsList: (_) => const LessonsListScreen(),
    lessonDetails: (_) => const LessonDetailsScreen(),
    videoPlayer: (_) => const VideoPlayerScreen(),
    pdfViewer: (_) => const PdfViewerScreen(),
    exercisesList: (_) => const ExercisesListScreen(),
    exerciseDetails: (_) => const ExerciseDetailsScreen(),
    downloads: (_) => const DownloadsScreen(),
    favorites: (_) => const FavoritesScreen(),
    notifications: (_) => const NotificationsScreen(),
    averageCalculator: (_) => const AverageCalculatorScreen(),
    profile: (_) => const ProfileScreen(),
    editProfile: (_) => const EditProfileScreen(),
    search: (_) => const SearchScreen(),
    progress: (_) => const ProgressScreen(),
    pastExams: (_) => const PastExamsScreen(),
    subjects: (_) => const SubjectsScreen(),
    mySubscription: (_) => const MySubscriptionScreen(),
    requestSubscription: (_) => const RequestSubscriptionScreen(),
  };
}
