# EvoMeet

A comprehensive Flutter application designed for building, managing, and engaging with AI communities. This platform enables seamless event organization, agenda planning (both manual and AI-powered), attendee management, and real-time feedback collection.

## 🚀 Features

### Core Functionality
- **Authentication**: Secure Login, Registration, OTP Verification, and Password Recovery.
- **Dashboard**: Centralized hub for managing events and notifications.
- **Event Management**:
  - Create and edit community events.
  - Detailed event views with agendas, attendees, and feedback.
  - Support for various event types (workshops, ceremonies, etc.).
- **Agenda Builder**:
  - **AI-Powered**: Generate event agendas automatically using AI.
  - **Manual Editor**: Fine-tune agendas with a drag-and-drop interface.
- **Attendee Management**: Track registrations, confirm attendees, and manage guest lists.
- **Engagement**:
  - **Feedback System**: Collect and analyze attendee feedback.
  - **Reminders**: Automated notifications for upcoming events.
- **Profile Management**: User profile editing and customization.
- **Settings**: Privacy policy, terms of service, and app configuration.

### Technical Highlights
- **Cross-Platform**: Optimized for both Mobile (Android/iOS) and Web.
- **Smart Platform Handling**: Firebase services are conditionally initialized only on mobile devices to ensure web compatibility.
- **Localization**: Support for English (`en`) and Hindi (`hi`).
- **Theming**: Light and Dark mode support with system preference detection.

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: `flutter_bloc` & Provider
- **Networking**: `dio` for robust API interactions
- **Backend Services**: 
  - **Firebase** (Mobile): Core, Crashlytics, Cloud Messaging
- **Local Storage**: `shared_preferences`
- **Utilities**:
  - `permission_handler`: For managing device permissions.
  - `url_launcher`: For opening external links.
  - `image_picker`: For profile and event image selection.
  - `intl`: For date and currency formatting.

## 🏁 Getting Started

### Prerequisites
- One of the following IDEs:
  - [Android Studio](https://developer.android.com/studio)
  - [VS Code](https://code.visualstudio.com/)
- Flutter SDK (v3.10.3 or higher)
- Dart SDK

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/empyreal-ai-community-builder-flutter.git
   cd empyreal-ai-community-builder-flutter
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   
   *For Mobile*:
   ```bash
   flutter run
   ```

   *For Web*:
   ```bash
   flutter run -d chrome
   ```

## 🏗️ Project Structure

```
lib/
├── blocs/          # BLoC state management logic
├── core/           # Core utilities
│   ├── animation/  # App-wide animations
│   ├── constants/  # API endpoints and static constants
│   ├── localization/ # Localization logic
│   └── theme/      # App colors and theme definitions
├── models/         # Data models (JSON serialization)
├── repositories/   # Data repositories (API calls)
├── screens/        # Feature-specific screens
│   ├── auth/       # Login, Register, OTP
│   ├── dashboard/  # Main dashboard
│   ├── events/     # Event creation and details
│   ├── notifications/# Notification center
│   └── settings/   # App settings
├── services/       # External services (API Client, Notification Service)
├── ui/             # Reusable UI components and widgets
└── main.dart       # Application entry point
```

## 📏 Coding Standards

This project utilizes a **custom extension syntax** to maintain clean and readable code. Before contributing, please review the coding guidelines:

- **[START_HERE.md](docs/coding-standards/START_HERE.md)**: Quick start guide (5 min read).
- **[EXTENSION_SYNTAX_CHEAT_SHEET.md](docs/coding-standards/EXTENSION_SYNTAX_CHEAT_SHEET.md)**: Syntax reference.
- **[CODING_RULES_AND_GUIDELINES.md](docs/coding-standards/CODING_RULES_AND_GUIDELINES.md)**: Detailed coding rules.

**Key Principles:**
- Use extension methods for padding, sizing, and alignment (e.g., `.paddingAll()`, `.width`, `.centerAlign`).
- Prioritize responsiveness using context extensions (e.g., `context.isMobile`).
- Avoid direct usage of `SizedBox` or `Padding` widgets where extensions can be used.

## 📚 Documentation

- [Deployment Guide](DEPLOYMENT_GUIDE.md)
- [Apache Web Deployment](APACHE_DEPLOYMENT.md)
- [Android Icon Fix](ANDROID_ICON_FIX.md)

## 🤝 Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
