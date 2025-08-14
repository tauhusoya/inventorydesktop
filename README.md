# Inventory Desktop - Firebase Authentication System

A Flutter desktop application with a comprehensive Firebase authentication system including login, registration, and password reset functionality.

## Features

### 🔐 Firebase Authentication
- **Secure Authentication**: Powered by Firebase Auth
- **User Registration**: Create accounts with email verification
- **User Login**: Secure sign-in with Firebase
- **Password Reset**: Email-based password recovery
- **Session Management**: Automatic authentication state management
- **Real-time Updates**: Live authentication state changes

### 🎨 User Interface
- **Modern Design**: Beautiful gradient backgrounds and Material Design 3
- **FlutterFire UI**: Professional authentication components
- **Responsive Layout**: Works on different screen sizes
- **Form Validation**: Real-time input validation with error messages
- **Loading States**: Smooth loading animations

### 🏗️ Architecture
- **Firebase Backend**: Secure cloud-based authentication
- **Provider Pattern**: State management using Provider
- **Service Layer**: Clean separation of business logic
- **Real-time Streams**: Firebase Auth state streams
- **Modular Structure**: Well-organized code structure

## Getting Started

### Prerequisites
- Flutter SDK (3.2.3 or higher)
- Dart SDK
- Windows/macOS/Linux for desktop development
- Firebase account
- FlutterFire CLI

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd inventorydesktop
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up Firebase:
   - Follow the [Firebase Setup Guide](FIREBASE_SETUP.md)
   - Run `flutterfire configure` to generate Firebase configuration
   - Update `lib/firebase_options.dart` with your Firebase project details

4. Run the application:
```bash
flutter run -d windows  # For Windows
flutter run -d macos     # For macOS
flutter run -d linux     # For Linux
```

## Firebase Configuration

### Required Setup
1. **Create Firebase Project**: Set up a new project in Firebase Console
2. **Enable Authentication**: Enable Email/Password authentication method
3. **Configure Flutter App**: Use FlutterFire CLI to configure your app
4. **Update Configuration**: Replace placeholder values in `firebase_options.dart`

### Authentication Methods
- **Email/Password**: Primary authentication method
- **Google Sign-In**: Optional (can be enabled later)
- **Phone Authentication**: Optional (can be enabled later)
- **Anonymous Auth**: Optional (can be enabled later)

## Project Structure

```
lib/
├── main.dart                 # Application entry point with Firebase init
├── firebase_options.dart     # Firebase configuration (generated)
├── services/
│   └── auth_service.dart     # Firebase authentication service
├── screens/
│   ├── auth/
│   │   └── auth_wrapper.dart     # FlutterFire UI authentication wrapper
│   └── home/
│       └── home_screen.dart      # Main dashboard
└── widgets/                      # Custom UI components
```

## Key Components

### Firebase Integration
- **Firebase Core**: App initialization and configuration
- **Firebase Auth**: User authentication and management
- **FlutterFire UI**: Pre-built authentication components
- **Real-time Streams**: Live authentication state updates

### Authentication Flow
1. **App Initialization**: Firebase is initialized on app start
2. **Auth State Check**: Stream-based authentication state monitoring
3. **User Registration**: Firebase handles user creation and validation
4. **User Login**: Secure authentication with Firebase
5. **Password Reset**: Email-based password recovery
6. **Session Management**: Automatic login state persistence

## Customization

### Firebase Configuration
Update `lib/firebase_options.dart` with your Firebase project details:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-api-key',
  appId: 'your-actual-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-project-id.firebaseapp.com',
  storageBucket: 'your-project-id.appspot.com',
);
```

### UI Customization
The app uses FlutterFire UI components which can be customized:

```dart
SignInScreen(
  styles: const {
    EmailFormStyle(signInButtonVariant: ButtonVariant.filled),
  },
  headerBuilder: (context, constraints, _) {
    // Custom header
  },
)
```

## Security Features

### Firebase Security
- **Secure Authentication**: Industry-standard security practices
- **Password Requirements**: Configurable password policies
- **Rate Limiting**: Built-in protection against brute force attacks
- **Email Verification**: Optional email verification requirement
- **User Management**: Admin controls for user accounts

### Best Practices
- Enable email verification for production apps
- Implement strong password policies
- Monitor authentication events in Firebase Console
- Use Firebase Security Rules for data access control

## Future Enhancements

- [ ] Google Sign-In integration
- [ ] Phone number authentication
- [ ] Multi-factor authentication (MFA)
- [ ] Social media login (Facebook, Twitter, etc.)
- [ ] User profile management
- [ ] Role-based access control
- [ ] Firestore database integration
- [ ] Real-time data synchronization

## Dependencies

- **flutter**: Core Flutter framework
- **firebase_core**: Firebase initialization
- **firebase_auth**: Firebase authentication
- **flutterfire_ui**: Pre-built Firebase UI components
- **provider**: State management

## Troubleshooting

### Common Issues
1. **Firebase not initialized**: Check `firebase_options.dart` configuration
2. **Authentication errors**: Verify Firebase Console settings
3. **Build failures**: Run `flutter clean` and `flutter pub get`

### Getting Help
- [Firebase Setup Guide](FIREBASE_SETUP.md)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support or questions:
1. Check the [Firebase Setup Guide](FIREBASE_SETUP.md)
2. Review Firebase Console for error messages
3. Open an issue in the repository
4. Consult Firebase community forums
