import 'package:empyreal_ai_community_builder_flutter/core/constants/api_constants.dart';
import 'package:empyreal_ai_community_builder_flutter/core/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'models/auth_models.dart';
import 'dart:ui';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'models/user.dart';
import 'models/event.dart';
import 'models/agenda_item.dart';
import 'models/attendee.dart';
import 'models/reminder.dart';
import 'models/feedback_response.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/webview_screen.dart';
import 'screens/auth/complete_profile_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'repositories/auth_repository.dart';
import 'services/api_client.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/events/create_event_screen.dart';
import 'screens/events/event_details_screen.dart';
import 'screens/events/ai_agenda_builder_screen.dart';
import 'screens/events/event_agenda_screen.dart';
import 'screens/events/manual_agenda_editor_screen.dart';
import 'screens/events/attendee_management_screen.dart';
import 'screens/events/reminder_settings_screen.dart';
import 'screens/events/feedback_collection_screen.dart';
import 'screens/events/feedback_reports_screen.dart';
import 'screens/notifications/notification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only on mobile platforms (skip on web)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();

      // Enable Crashlytics collection
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

      // Pass all uncaught "fatal" errors from the framework to Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      
      // Setup FCM using the new service only on mobile
      await NotificationService().initialize();
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
      // Continue app execution even if Firebase fails
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Event Builder',
      theme: AppTheme.lightTheme,
      home: const AppNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  String _currentPage = 'login';
  User? _user;
  String _tempMobileNo = '';
  String _tempUserId = '';
  String _token = '';
  bool _isNewUser = false;
  List<Event> _events = [];
  Event? _currentEvent;
  List<AgendaItem> _agendaItems = [];
  List<Attendee> _attendees = [];
  List<Reminder> _reminders = [];
  List<FeedbackResponse> _feedbackResponses = [];
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadMockData();
    _checkLoginStatus();
  }

  Future<void> _checkPermissions() async {
    if (!kIsWeb) {
      await [
        Permission.locationWhenInUse,
        Permission.notification,
      ].request();
    }
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userData = prefs.getString('user');

      if (token != null && userData != null && token.isNotEmpty) {
        final decodedUser = jsonDecode(userData);
        setState(() {
          _token = token;
          _user = User.fromJson(decodedUser);
          _currentPage = 'dashboard';
        });
        _fetchUnreadCount();
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
    }
  }

  Future<void> _fetchUnreadCount() async {
    if (_token.isEmpty) return;
    try {
      final response = await AuthRepository(ApiClient()).getUnreadCount(_token);
      if (mounted) {
        setState(() {
          _unreadNotificationCount = response.unreadCount;
        });
      }
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  void _loadMockData() {
    _events = [
      Event(
        id: '1',
        name: 'Holi Community Event 2026',
        description: 'A vibrant celebration of colors and culture',
        type: 'cultural',
        date: '2026-03-15',
        duration: 7,
        audienceSize: 200,
        planningMode: 'automated',
        status: 'published',
        createdAt: '2026-01-10',
        attendeeCount: 156,
        location: '23.54455-23.555566'
      ),
      Event(
        id: '2',
        name: 'Tech Workshop Series',
        description: 'Three-day workshop on AI and Machine Learning',
        type: 'workshop',
        date: '2026-02-20',
        endDate: '2026-02-22',
        duration: 6,
        audienceSize: 50,
        planningMode: 'manual',
        status: 'ongoing',
        createdAt: '2026-01-15',
        attendeeCount: 48,
          location: '23.54455-23.555566'
      ),
    ];
  }

  void _handleLoginSuccess(String userId, String mobileNo, bool isNewUser) {
    setState(() {
      _tempUserId = userId;
      _tempMobileNo = mobileNo;
      _isNewUser = isNewUser;
      _currentPage = 'otp';
    });
  }

  Future<void> _handleOtpVerified(UserModel user, String token) async {
    setState(() {
      _token = token;
      if (_isNewUser) {
        _currentPage = 'complete-profile';
      } else {
        _user = User(
          id: user.id,
          name: user.name,
          email: user.email,
          profilePic: user.profilePic,
        );
        _currentPage = 'dashboard';
      }
    });
    if (!_isNewUser) {
      await _saveSession(user, token);
    }
  }

  Future<void> _saveSession(dynamic user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    User sessionUser;
    if (user is UserModel) {
      sessionUser = User(
        id: user.id,
        name: user.name,
        email: user.email,
        profilePic: user.profilePic,
      );
    } else {
      sessionUser = user as User;
    }
    await prefs.setString('user', jsonEncode(sessionUser.toJson()));
  }

  Future<void> _handleProfileCompleted(String name, String profilePic) async {
    setState(() {
      _user = User(
        id: _tempUserId,
        name: name,
        email: null,
        profilePic: profilePic,
      );
      _currentPage = 'dashboard';
    });
    await _saveSession(_user!, _token);
  }

  Future<void> _handleProfileUpdated(String name, String profilePic) async {
    setState(() {
      _user = User(
        id: _user!.id,
        name: name,
        email: _user!.email,
        profilePic: profilePic,
      );
      _currentPage = 'profile';
    });
    await _saveSession(_user!, _token);
  }

  void _handleRegister(String name, String email, String password) {
    setState(() {
      _user = User(
        id: '1',
        name: name,
        email: email,
      );
      _currentPage = 'dashboard';
    });
  }

  void _handleLogout() async {
    try {
      if (_token.isNotEmpty) {
        await AuthRepository(ApiClient()).logout(_token);
      }
    } catch (e) {
      debugPrint('Logout API Error: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _user = null;
      _token = '';
      _currentPage = 'login';
      _currentEvent = null;
    });
  }

  void _handleCreateEvent(Event event) {
    setState(() {
      _events.add(event);
      _currentEvent = event;
      _currentPage = 'manual-agenda';
    });
  }


  void _handleSelectEvent(Event event) {
    setState(() {
      _currentEvent = event;
      _currentPage = 'event-details';
      
      // Load mock data for this event
      if (event.id == '1') {
        _agendaItems = [
          AgendaItem(
            id: 'a1',
            title: 'Welcome Session',
            startTime: '09:00',
            endTime: '09:30',
            type: 'ceremony',
            description: 'Opening ceremony and welcome address',
          ),
          AgendaItem(
            id: 'a2',
            title: 'Ice-breaking Activities',
            startTime: '09:30',
            endTime: '10:30',
            type: 'activity',
          ),
          AgendaItem(
            id: 'a3',
            title: 'Tea Break',
            startTime: '10:30',
            endTime: '10:45',
            type: 'break',
          ),
        ];

        _attendees = [
          Attendee(
            id: '1',
            name: 'Alice Kumar',
            email: 'alice@example.com',
            phone: '+91-9876543210',
            registeredAt: '2026-02-10',
            status: 'confirmed',
          ),
          Attendee(
            id: '2',
            name: 'Bob Sharma',
            email: 'bob@example.com',
            registeredAt: '2026-02-12',
            status: 'registered',
          ),
        ];

        _reminders = [
          Reminder(
            id: 'r1',
            type: 'event-start',
            timing: '1 day before',
            message: 'Event starts tomorrow!',
            enabled: true,
          ),
        ];

        _feedbackResponses = [
          FeedbackResponse(
            id: 'f1',
            attendeeId: '1',
            attendeeName: 'Alice Kumar',
            rating: 5,
            comments: 'Amazing event! Loved the cultural performances.',
            submittedAt: '2026-03-16',
          ),
        ];
      }
    });
  }

  void _handleSaveAgenda(List<AgendaItem> items) {
    setState(() {
      _agendaItems = items;
      _currentPage = 'dashboard';
    });
  }


  void _handleAddAttendee(Attendee attendee) {
    setState(() {
      _attendees.add(attendee);
    });
  }

  void _handleUpdateReminders(List<Reminder> reminders) {
    setState(() {
      _reminders = reminders;
    });
  }

  void _handleSubmitFeedback(FeedbackResponse feedback) {
    setState(() {
      _feedbackResponses.add(feedback);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: _buildPage(),
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentPage == 'login' || _currentPage == 'dashboard') {
      return true;
    }

    setState(() {
      switch (_currentPage) {
        case 'register':
        case 'forgot-password':
        case 'otp':
          _currentPage = 'login';
          break;
        case 'create-event':
        case 'event-details':
          _currentPage = 'dashboard';
          break;
        case 'ai-agenda':
        case 'manual-agenda':
        case 'agenda-view':
        case 'attendees':
        case 'reminders':
        case 'feedback-collection':
        case 'feedback-reports':
        case 'profile':
        case 'edit-profile':
        case 'settings':
        case 'privacy':
        case 'terms':
        case 'notifications':
          _currentPage = 'dashboard';
          break;
        default:
          _currentPage = 'dashboard';
      }
    });
    return false;
  }

  Widget _buildPage() {
    switch (_currentPage) {
      case 'login':
        return LoginScreen(
          onLoginSuccess: _handleLoginSuccess,
          onNavigateToRegister: () => setState(() => _currentPage = 'register'),
          onNavigateToForgotPassword: () => setState(() => _currentPage = 'forgot-password'),
        );

      case 'otp':
        return OtpScreen(
          userId: _tempUserId,
          mobileNo: _tempMobileNo,
          onOtpVerified: _handleOtpVerified,
          onBack: () => setState(() => _currentPage = 'login'),
        );

      case 'complete-profile':
        return CompleteProfileScreen(
          userId: _tempUserId,
          token: _token,
          onProfileCompleted: _handleProfileCompleted,
        );

      case 'register':
        return RegisterScreen(
          onRegister: _handleRegister,
          onNavigateToLogin: () => setState(() => _currentPage = 'login'),
        );
      
      case 'forgot-password':
        return ForgotPasswordScreen(
          onNavigateToLogin: () => setState(() => _currentPage = 'login'),
        );
      
      case 'dashboard':
        return DashboardScreen(
          user: _user!,
          token: _token,
          onCreateEvent: () => setState(() => _currentPage = 'create-event'),
          onSelectEvent: _handleSelectEvent,
          onLogout: _handleLogout,
          onNavigateToProfile: () => setState(() => _currentPage = 'profile'),
          onNavigateToSettings: () => setState(() => _currentPage = 'settings'),
          onNavigateToNotifications: () async {
            setState(() => _currentPage = 'notifications');
          },
          unreadCount: _unreadNotificationCount,
        );
      
      case 'notifications':
        return NotificationScreen(
          token: _token,
          onBack: () {
            setState(() => _currentPage = 'dashboard');
            _fetchUnreadCount();
          },
        );
      
      case 'settings':
        return SettingsScreen(
          onBack: () => setState(() => _currentPage = 'dashboard'),
          onLogout: _handleLogout,
          onNavigateToProfile: () => setState(() => _currentPage = 'profile'),
          onNavigateToPrivacy: () => setState(() => _currentPage = 'privacy'),
          onNavigateToTerms: () => setState(() => _currentPage = 'terms'),
        );
      
      case 'privacy':
        return AppWebViewScreen(
          title: 'Privacy Policy',
          url: '${ApiConstants.baseUrl}/privacy-policy',
          onBack: () => setState(() => _currentPage = 'settings'),
        );
      
      case 'terms':
        return AppWebViewScreen(
          title: 'Terms & Conditions',
          url: '${ApiConstants.baseUrl}/terms-and-conditions',
          onBack: () => setState(() => _currentPage = 'settings'),
        );

      case 'profile':
        return ProfileScreen(
          token: _token,
          onBack: () => setState(() => _currentPage = 'dashboard'),
          onLogout: _handleLogout,
          onEditProfile: (user) => setState(() {
            _user = user;
            _currentPage = 'edit-profile';
          }),
        );
      
      case 'edit-profile':
        return EditProfileScreen(
          user: _user!,
          token: _token,
          onProfileUpdated: _handleProfileUpdated,
          onBack: () => setState(() => _currentPage = 'profile'),
        );
      
      case 'create-event':
        return CreateEventScreen(
          onCreateEvent: _handleCreateEvent,
          onBack: () => setState(() => _currentPage = 'dashboard'),
          user: _user!,
          token: _token,
        );
      
      case 'event-details':
        return EventDetailsScreen(
          event: _currentEvent!,
          agendaItems: _agendaItems,
          attendees: _attendees,
          onNavigate: (page) => setState(() => _currentPage = page),
          onBack: () => setState(() => _currentPage = 'dashboard'),
          user: _user!,
        );
      
      case 'ai-agenda':
        return AIAgendaBuilderScreen(
          event: _currentEvent!,
          onSaveAgenda: _handleSaveAgenda,
          onBack: () => setState(() => _currentPage = 'event-details'),
          user: _user!,
        );

      case 'agenda-view':
        return EventAgendaScreen(
          event: _currentEvent!,
          agendaItems: _agendaItems,
          onBack: () => setState(() => _currentPage = 'event-details'),
          onEditAgenda: () => setState(
            () => _currentPage =
                _currentEvent!.planningMode == 'automated' ? 'ai-agenda' : 'manual-agenda',
          ),
        );
      
      case 'manual-agenda':
        return ManualAgendaEditorScreen(
          event: _currentEvent!,
          existingAgenda: _agendaItems,
          onSaveAgenda: _handleSaveAgenda,
          onBack: () => setState(() => _currentPage = 'event-details'),
          user: _user!,
          token: _token,
        );
      
      case 'attendees':
        return AttendeeManagementScreen(
          event: _currentEvent!,
          attendees: _attendees,
          onAddAttendee: _handleAddAttendee,
          onBack: () => setState(() => _currentPage = 'event-details'),
          user: _user!,
        );
      
      // case 'reminders':
      //   return ReminderSettingsScreen(
      //     event: _currentEvent!,
      //     reminders: _reminders,
      //     onUpdateReminders: _handleUpdateReminders,
      //     onBack: () => setState(() => _currentPage = 'event-details'),
      //     user: _user!,
      //   );
      
      case 'feedback-collection':
        return FeedbackCollectionScreen(
          event: _currentEvent!,
          onSubmitFeedback: _handleSubmitFeedback,
          onBack: () => setState(() => _currentPage = 'event-details'),
        );
      
      // case 'feedback-reports':
      //   return FeedbackReportsScreen(
      //     event: _currentEvent!,
      //     feedbackResponses: _feedbackResponses,
      //     onBack: () => setState(() => _currentPage = 'event-details'),
      //     user: _user!,
      //   );
      
      default:
        return LoginScreen(
          onLoginSuccess: _handleLoginSuccess,
          onNavigateToRegister: () => setState(() => _currentPage = 'register'),
          onNavigateToForgotPassword: () => setState(() => _currentPage = 'forgot-password'),
        );
    }
  }
}
