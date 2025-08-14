# Inventory Desktop App

A Flutter-based inventory management application.

<!-- Deployment test -->

## Features

- User authentication and management
- Inventory item management
- Stock tracking
- Profile management
- Responsive design for desktop and mobile

## Web Deployment

This app is configured for web deployment and can be hosted on GitHub Pages, Netlify, or any static hosting service.

### Building for Web

```bash
flutter build web --base-href /
```

### GitHub Pages Deployment

1. Push your code to GitHub
2. Go to your repository Settings > Pages
3. Set Source to "Deploy from a branch"
4. Select the `gh-pages` branch (or create it)
5. Set folder to `/ (root)`
6. Save the settings

### Netlify Deployment

1. Connect your GitHub repository to Netlify
2. Set build command: `flutter build web --base-href /`
3. Set publish directory: `build/web`
4. Deploy

### Local Testing

To test the web build locally:

```bash
# Build the app
flutter build web --base-href /

# Serve using Python (if available)
cd build/web
python -m http.server 8000

# Or use any local server
# Navigate to http://localhost:8000
```

## Development

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Git

### Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd inventorydesktop

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome
```

## Configuration

Make sure to configure your Firebase and R2 storage settings in the respective config files:

- `lib/config/firebase_options.dart`
- `lib/config/r2_config.dart`

## License

This project is licensed under the MIT License.
