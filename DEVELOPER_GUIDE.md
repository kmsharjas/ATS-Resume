# ATS Resume Builder - Developer Guide

## 🏗️ Architecture Overview

### State Management with Provider
The app uses Provider for clean, reactive state management:

```dart
// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ResumeProvider()),
    ChangeNotifierProvider(create: (_) => JobDescriptionProvider()),
  ],
  child: MyApp(),
)
```

### Data Flow
```
User Input → Widget Event → Provider Method → State Update → UI Rebuild
```

## 📦 Package Integration Guide

### PDF Export Setup

**Android Configuration** (`android/app/build.gradle`):
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
    }
}
```

**iOS Configuration** (`ios/Podfile`):
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

**Implementation Example**:
```dart
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

Future<void> exportToPDF(Resume resume) async {
  final pdf = await PDFExportService.generatePDF(resume);
  await Printing.layoutPdf(
    onLayout: (_) => pdf.save(),
    name: '${resume.contactInfo.fullName}_Resume.pdf',
  );
}
```

### DOCX Export Setup

**Implementation Example**:
```dart
import 'package:docx/docx.dart';

Future<void> exportToDocx(Resume resume) async {
  final docContent = DocxExportService.generateDocx(resume);
  // Save to device storage
}
```

### Database Setup (SQLite)

**Enable sqflite** in `pubspec.yaml` and create models:

```dart
class ResumeDatabase {
  static final ResumeDatabase _instance = ResumeDatabase._internal();
  
  factory ResumeDatabase() {
    return _instance;
  }
  
  ResumeDatabase._internal();
  
  Database? _database;
  
  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }
  
  Future<Database> _initDB() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'resume_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE resumes(id TEXT PRIMARY KEY, data TEXT, createdAt TEXT, updatedAt TEXT)',
        );
      },
      version: 1,
    );
  }
}
```

## 🎨 UI Component Library

### Custom Form Field
```dart
class ATSFormField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const ATSFormField({
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
    );
  }
}
```

### ATS Score Indicator
```dart
class ATSScoreIndicator extends StatelessWidget {
  final int score;

  const ATSScoreIndicator({required this.score});

  Color _getColor() {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$score%',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _getColor(),
          ),
        ),
        LinearProgressIndicator(
          value: score / 100,
          valueColor: AlwaysStoppedAnimation(_getColor()),
        ),
      ],
    );
  }
}
```

## 🔄 API Integration (Future)

### REST API Structure
```dart
class APIService {
  static const String baseURL = 'https://api.resumebuilder.com';
  
  static Future<Map<String, dynamic>> analyzeJobDescription(String jobDesc) async {
    final response = await http.post(
      Uri.parse('$baseURL/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'description': jobDesc}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to analyze job description');
    }
  }
}
```

## 🧪 Testing Guide

### Unit Tests
```dart
// test/models/resume_model_test.dart
void main() {
  group('Resume Model Tests', () {
    test('Resume sorts work experience in reverse chronological order', () {
      final resume = Resume(
        id: 'test',
        templateName: 'Classic',
        contactInfo: ContactInfo(...),
        workExperience: [...],
        education: [],
        skills: [],
      );
      
      expect(resume.sortedWorkExperience.first.startDate.isAfter(
        resume.sortedWorkExperience.last.startDate
      ), true);
    });
  });
}
```

### Widget Tests
```dart
// test/widgets/contact_info_step_test.dart
void main() {
  group('ContactInfoStep Widget Tests', () {
    testWidgets('Displays all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp());
      
      expect(find.byType(TextField), findsWidgets);
      expect(find.byText('Full Name *'), findsOneWidget);
      expect(find.byText('Email *'), findsOneWidget);
    });
  });
}
```

## 🚀 Performance Optimization

### Memory Management
```dart
// Use lazy loading for large lists
ListView.builder(
  itemCount: experiences.length,
  itemBuilder: (context, index) {
    return _buildExperienceCard(experiences[index]);
  },
)
```

### Build Optimization
```dart
// Use const constructors
const MyWidget();

// Use shouldRebuild to prevent unnecessary rebuilds
class MyNotifier extends ChangeNotifier {
  void updateValue(String value) {
    if (_value != value) {
      _value = value;
      notifyListeners();
    }
  }
}
```

## 🔐 Security Best Practices

### Data Protection
- Store sensitive data using `flutter_secure_storage`
- Encrypt resume data before cloud sync
- Implement proper session management

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

// Save resume data securely
await storage.write(
  key: 'resume_data',
  value: jsonEncode(resume.toJson()),
);

// Retrieve resume data
final resumeData = await storage.read(key: 'resume_data');
```

### Input Validation
```dart
class Validators {
  static String? validateEmail(String? value) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    final regex = RegExp(r'^[\d\-\+\(\)\s]{10,}$');
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    if (!regex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
```

## 📱 Platform-Specific Implementation

### Android Permissions (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS Permissions (`ios/Runner/Info.plist`)
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs access to export and manage files</string>
<key>NSBonjourServiceTypes</key>
<array>
  <string>_http._tcp</string>
</array>
```

## 📊 Analytics Integration (Future)

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logResumeCreated() async {
    await _analytics.logEvent(
      name: 'resume_created',
      parameters: {'timestamp': DateTime.now().toString()},
    );
  }
  
  static Future<void> logExport(String format) async {
    await _analytics.logEvent(
      name: 'resume_exported',
      parameters: {'format': format},
    );
  }
}
```

## 🐛 Debugging Tips

### Enable Debug Logging
```dart
import 'package:logger/logger.dart';

final logger = Logger();

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

### Hot Reload Development
```bash
flutter run
# Press 'r' for hot reload
# Press 'R' for hot restart
```

### Device Testing
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Enable device logging
flutter logs
```

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io)
- [Dart Language Guide](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)
- [PDF Package](https://pub.dev/packages/pdf)

---

**Happy Coding! 🚀**
