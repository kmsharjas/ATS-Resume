# Platform-Specific Implementation Notes

## iOS Configuration

### Update iOS Build Settings
**File: ios/Podfile**

Ensure minimum deployment target:
```ruby
platform :ios, '12.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

### Update Permissions
**File: ios/Runner/Info.plist**

Add these keys for file export:
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs to access your files for export functionality</string>
<key>NSBonjourServiceTypes</key>
<array>
    <string>_http._tcp</string>
    <string>_https._tcp</string>
</array>
<key>NSDocumentsFolderUsageDescription</key>
<string>This app needs access to your documents folder</string>
```

### Build Command
```bash
flutter build ios --release
```

---

## Android Configuration

### Update Build Gradle
**File: android/app/build.gradle**

```gradle
android {
    compileSdkVersion 34
    ndkVersion "25.1.8937393"

    defaultConfig {
        applicationId "com.atsresume.resumebuilder"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Update Permissions
**File: android/app/src/main/AndroidManifest.xml**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Required Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    
    <!-- File Management -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <!-- For Android 10+ (Scoped Storage) -->
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
    
    <!-- Rest of manifest content -->
</manifest>
```

### Build Command
```bash
flutter build apk --release
# For App Bundle
flutter build appbundle --release
```

---

## Web Configuration

### Update Web Index
**File: web/index.html**

Ensure proper meta tags:
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta content="IE=Edge" http-equiv="X-UA-Compatible">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ATS Resume Builder</title>
    <link rel="icon" type="image/png" href="favicon.png">
</head>
<body>
    <script>
        if (window.flutterWebRenderer == "auto") {
            window.flutterWebRenderer = "canvaskit";
        }
    </script>
    <script src="flutter.js" defer></script>
</body>
</html>
```

### Configure Web App
**File: web/manifest.json**

```json
{
    "name": "ATS Resume Builder",
    "short_name": "Resume Builder",
    "start_url": "/",
    "display": "standalone",
    "background_color": "#ffffff",
    "theme_color": "#1f77f2",
    "orientation": "portrait-primary",
    "icons": [
        {
            "src": "icons/Icon-192.png",
            "sizes": "192x192",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
        }
    ]
}
```

### Build Command
```bash
flutter build web --release
# Serve locally for testing
flutter run -d web-server
```

---

## Responsive Breakpoints

The app uses these breakpoints for responsive design:

```dart
// Mobile-first approach
if (MediaQuery.of(context).size.width < 768) {
    // Mobile layout (single column)
} else {
    // Desktop layout (two columns)
}
```

### Breakpoints
- **Mobile**: < 768px (Single column, bottom navigation)
- **Tablet**: 768px - 1024px (Two columns, adaptive sidebar)
- **Desktop**: > 1024px (Full layout with sidebar and preview)

---

## Font Configuration

### Custom Fonts
Add to **pubspec.yaml**:
```yaml
fonts:
  - family: Roboto
    fonts:
      - asset: assets/fonts/Roboto-Regular.ttf
      - asset: assets/fonts/Roboto-Bold.ttf
        weight: 700
      - asset: assets/fonts/Roboto-Italic.ttf
        style: italic
  - family: Calibri
    fonts:
      - asset: assets/fonts/Calibri-Regular.ttf
      - asset: assets/fonts/Calibri-Bold.ttf
        weight: 700
```

### ATS-Safe Font Hierarchy
1. **Primary**: System default (Roboto on Android, San Francisco on iOS)
2. **Secondary**: Calibri
3. **Fallback**: Arial

---

## Testing Across Platforms

### iOS Testing
```bash
# Run tests on iOS simulator
flutter test -d iOS

# Run specific test file
flutter test test/ios_specific_test.dart
```

### Android Testing
```bash
# Run tests on Android emulator
flutter test -d Android

# Run specific test file
flutter test test/android_specific_test.dart
```

### Web Testing
```bash
# Run tests in Chrome
flutter test -d web

# Debug tests
flutter test --start-paused test/web_specific_test.dart
```

---

## Deployment Checklist

### Pre-Deployment
- [ ] Update version number in `pubspec.yaml`
- [ ] Update app version in platform-specific files
- [ ] Test on all target devices/browsers
- [ ] Run `flutter analyze` for code quality
- [ ] Run all tests: `flutter test`
- [ ] Build in release mode: `flutter build [platform] --release`

### iOS Deployment
- [ ] Create App Store Connect account
- [ ] Update bundle identifier
- [ ] Generate signing certificates
- [ ] Build IPA: `flutter build ios --release`
- [ ] Upload via Xcode or Transporter

### Android Deployment
- [ ] Create Google Play Developer account
- [ ] Generate signing key
- [ ] Update app signing configuration
- [ ] Build App Bundle: `flutter build appbundle --release`
- [ ] Upload to Google Play Console

### Web Deployment
- [ ] Configure web hosting (Firebase Hosting, Vercel, etc.)
- [ ] Set up HTTPS certificate
- [ ] Configure CORS headers if needed
- [ ] Build: `flutter build web --release`
- [ ] Deploy built files

---

## Platform-Specific Troubleshooting

### iOS Issues
```bash
# Clean iOS build
rm -rf ios/Pods ios/Podfile.lock
flutter clean
flutter pub get
flutter build ios

# Debug on device
flutter attach -d <device_id>
```

### Android Issues
```bash
# Clean Android build
rm -rf android/.gradle android/build
flutter clean
flutter pub get
flutter build apk

# Debug on device
adb logcat | grep flutter
```

### Web Issues
```bash
# Clear browser cache
flutter clean
flutter build web --release

# Debug in browser
# Press F12 and check Console for errors
```

---

## Performance Optimization Per Platform

### iOS
- Use `flutter_native_splash` for faster app launch
- Minimize initial asset loading
- Profile with Instruments

### Android
- Enable ProGuard minification
- Use `flutter_native_splash`
- Profile with Android Profiler

### Web
- Use CanvasKit renderer for better compatibility
- Implement lazy loading for images
- Minify JavaScript output

---

## Distribution URLs

Once deployed:

- **iOS App Store**: [Your App Store Link]
- **Google Play Store**: [Your Play Store Link]
- **Web Application**: [Your Web URL]

---

**Remember to test thoroughly on all platforms before release!**
