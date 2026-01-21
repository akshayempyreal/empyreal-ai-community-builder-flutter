import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'theme/app_theme.dart';
import 'models/user.dart';
import 'models/event.dart';
import 'models/agenda_item.dart';
import 'models/attendee.dart';
import 'models/reminder.dart';
import 'models/feedback_response.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/events/create_event_screen.dart';
import 'screens/events/event_details_screen.dart';
import 'screens/events/ai_agenda_builder_screen.dart';
import 'screens/events/manual_agenda_editor_screen.dart';
import 'screens/events/attendee_management_screen.dart';
import 'screens/events/reminder_settings_screen.dart';
import 'screens/events/feedback_collection_screen.dart';
import 'screens/events/feedback_reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  List<Event> _events = [];
  Event? _currentEvent;
  List<AgendaItem> _agendaItems = [];
  List<Attendee> _attendees = [];
  List<Reminder> _reminders = [];
  List<FeedbackResponse> _feedbackResponses = [];

  @override
  void initState() {
    super.initState();
    _loadMockData();
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
      ),
    ];
  }

  void _handleLogin(String email, String password) {
    setState(() {
      _user = User(
        id: '1',
        name: 'John Organizer',
        email: email,
      );
      _currentPage = 'dashboard';
    });
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

  void _handleLogout() {
    setState(() {
      _user = null;
      _currentPage = 'login';
      _currentEvent = null;
    });
  }

  void _handleCreateEvent(Event event) {
    setState(() {
      _events.add(event);
      _currentEvent = event;
      if (event.planningMode == 'automated') {
        _currentPage = 'ai-agenda';
      } else {
        _currentPage = 'manual-agenda';
      }
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
          _currentPage = 'login';
          break;
        case 'create-event':
        case 'event-details':
          _currentPage = 'dashboard';
          break;
        case 'ai-agenda':
        case 'manual-agenda':
        case 'attendees':
        case 'reminders':
        case 'feedback-collection':
        case 'feedback-reports':
          _currentPage = 'event-details';
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
          onLogin: _handleLogin,
          onNavigateToRegister: () => setState(() => _currentPage = 'register'),
          onNavigateToForgotPassword: () => setState(() => _currentPage = 'forgot-password'),
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
          events: _events,
          onCreateEvent: () => setState(() => _currentPage = 'create-event'),
          onSelectEvent: _handleSelectEvent,
          onLogout: _handleLogout,
        );
      
      case 'create-event':
        return CreateEventScreen(
          onCreateEvent: _handleCreateEvent,
          onBack: () => setState(() => _currentPage = 'dashboard'),
          user: _user!,
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
      
      case 'manual-agenda':
        return ManualAgendaEditorScreen(
          event: _currentEvent!,
          existingAgenda: _agendaItems,
          onSaveAgenda: _handleSaveAgenda,
          onBack: () => setState(() => _currentPage = 'event-details'),
          user: _user!,
        );
      
      case 'attendees':
        return AttendeeManagementScreen(
          event: _currentEvent!,
          attendees: _attendees,
          onAddAttendee: _handleAddAttendee,
          onBack: () => setState(() => _currentPage = 'event-details'),
          user: _user!,
        );
      
      case 'reminders':
        return ReminderSettingsScreen(
          event: _currentEvent!,
          reminders: _reminders,
          onUpdateReminders: _handleUpdateReminders,
          onBack: () => setState(() => _currentPage = 'event-details'),
          user: _user!,
        );
      
      case 'feedback-collection':
        return FeedbackCollectionScreen(
          event: _currentEvent!,
          onSubmitFeedback: _handleSubmitFeedback,
          onBack: () => setState(() => _currentPage = 'event-details'),
        );
      
      case 'feedback-reports':
        return FeedbackReportsScreen(
          event: _currentEvent!,
          feedbackResponses: _feedbackResponses,
          onBack: () => setState(() => _currentPage = 'event-details'),
          user: _user!,
        );
      
      default:
        return LoginScreen(
          onLogin: _handleLogin,
          onNavigateToRegister: () => setState(() => _currentPage = 'register'),
          onNavigateToForgotPassword: () => setState(() => _currentPage = 'forgot-password'),
        );
    }
  }
}
