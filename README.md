# ATS Resume Builder - Flutter Application

A professional, cross-platform resume builder application designed to create ATS (Applicant Tracking System) optimized resumes that pass modern job screening systems while maintaining clean, modern UI/UX.

## 🎯 Overview

This Flutter application provides a comprehensive solution for creating professional resumes that are:
- **ATS-Compliant**: Single-column layouts, standard fonts, machine-readable formats
- **User-Friendly**: Step-by-step guided workflow with real-time preview
- **Intelligent**: AI-powered suggestions, job description matching, and optimization feedback
- **Multi-Platform**: Native experiences on Android, iOS, and Web

## 🚀 Features

### Core Resume Building
- **Step-by-Step Workflow** (6 intuitive steps)
  1. Contact Information
  2. Professional Summary
  3. Work Experience
  4. Education
  5. Skills
  6. Review & Export

- **Dynamic Content Management**
  - Add, edit, and delete resume sections
  - Automatic reverse chronological sorting
  - Real-time character count and validation

### ATS Optimization
- **Real-Time Feedback Panel**
  - Compatibility score (0-100%)
  - Issue identification with actionable fixes
  - Formatting validation
  
- **Automated Checks**
  - Consistent date formatting
  - Keyword density analysis
  - Quantifiable achievement detection
  - Completeness scoring

### Intelligent Features
- **Job Description Analyzer**
  - Paste job postings to extract keywords
  - Calculate resume match percentage
  - Identify missing skills
  - Get targeted recommendations
  
- **Content Suggestions**
  - Action verb recommendations by role
  - Achievement template library (STAR method)
  - Skill suggestions based on job title
  - Real-time quality feedback on bullet points

### Export & Preview
- **Live Preview**
  - WYSIWYG resume preview
  - Clean, professional formatting
  - Mobile and desktop viewing
  
- **Multiple Export Formats**
  - PDF (text-searchable, ATS-friendly)
  - DOCX (Microsoft Word compatible)
  - Clean formatting preservation

## 📋 Technical Architecture

### Project Structure
```
lib/
├── main.dart                          # App entry point
├── models/
│   └── resume_model.dart             # Data models (Resume, ContactInfo, etc.)
├── providers/
│   ├── resume_provider.dart          # State management for resume
│   └── job_description_provider.dart # Job analyzer state
├── services/
│   ├── ats_validator.dart            # ATS validation logic
│   ├── content_suggestions.dart      # AI suggestions
│   ├── pdf_export_service.dart       # PDF generation
│   └── docx_export_service.dart      # DOCX generation
└── screens/
    ├── home_screen.dart              # Landing page
    ├── resume_builder_screen.dart    # Main builder layout
    └── resume_steps/
        ├── contact_info_step.dart
        ├── summary_step.dart
        ├── work_experience_step.dart
        ├── education_step.dart
        ├── skills_step.dart
        ├── review_step.dart
        ├── resume_preview_screen.dart
        └── job_description_screen.dart
```

### Key Technologies
- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Data Models**: Serializable JSON
- **PDF Generation**: `pdf` package + `printing`
- **DOCX Generation**: `docx` package
- **Storage**: `shared_preferences` + `sqflite`
- **UI**: Material Design 3 + Cupertino

## 🛠 Setup & Installation

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Visual Studio Code or Android Studio (recommended IDE)

### Installation Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd ats-resume
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
# For web
flutter run -d web

# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

4. **Build for release**
```bash
# Web
flutter build web

# Android APK
flutter build apk

# iOS App
flutter build ios
```

## 📱 Platform-Specific Features

### Android
- Material Design 3 theme
- Native Android widgets
- Optimized for various screen sizes

### iOS
- Cupertino (iOS-style) widgets
- Native iOS appearance
- Support for iOS 12+

### Web
- Responsive design
- Desktop-optimized layout with sidebar navigation
- Cross-browser compatibility

## 🎨 UI/UX Highlights

### Mobile Layout
- **Bottom navigation** with step progress
- **Full-screen forms** for each step
- **Collapsible sections** to save space
- **Touch-optimized** controls

### Desktop Layout
- **Sidebar navigation** with visual step indicators
- **Two-column layout** (navigation + content)
- **Live preview panel** (optional)
- **Keyboard shortcuts** support

### Responsive Design
- Automatic layout switching at 768px breakpoint
- Adaptive font sizing
- Flexible padding and spacing
- Touch-friendly tap targets

## 🔍 ATS Validation Rules

The app validates resumes against ATS best practices:

### Required Fields
- Full name, email, phone, location
- At least one work experience or education entry
- At least 5 skills

### Format Checks
- Consistent date formatting (MMM YYYY)
- Single-column layout (enforced)
- Standard fonts only (Arial, Calibri, Roboto, San Francisco)
- No images, tables, or complex formatting

### Content Checks
- Minimum keyword presence
- Action verb usage (led, managed, developed, etc.)
- Quantifiable metrics in achievements
- Professional summary (under 300 characters)

### Warnings Generated For
- Inconsistent date formats
- Low keyword density
- Missing quantifiable metrics
- Incomplete sections
- Generic or weak bullet points

## 💾 Data Management

### Local Storage
- **SharedPreferences**: Quick settings and last resume ID
- **SQLite (sqflite)**: Full resume storage and history
- **JSON Serialization**: Easy import/export

### Data Model Features
```dart
Resume {
  id: String
  templateName: String
  contactInfo: ContactInfo
  summary: Summary?
  workExperience: List<WorkExperience>
  education: List<Education>
  skills: List<Skill>
  createdAt: DateTime
  updatedAt: DateTime
}
```

### Auto-Save
- Changes saved automatically after each section
- Resume history tracking
- Undo capability (future enhancement)

## 🤖 AI & Suggestion Engine

### Action Verb Suggestions
Categorized by role type:
- **Leadership**: Led, Directed, Managed, Coordinated
- **Achievement**: Accomplished, Achieved, Exceeded, Improved
- **Technical**: Developed, Implemented, Engineered, Designed
- **Analysis**: Analyzed, Evaluated, Assessed, Examined
- **Communication**: Communicated, Presented, Negotiated, Collaborated

### Achievement Templates (STAR Method)
- Increased [metric] by [number]%
- Reduced [metric] through [action]
- Led a team of [number] to [achievement]
- Improved [process] efficiency
- Managed budget of [$amount] with [result]

### Content Quality Feedback
- Keyword density analysis
- Quantifiable metric detection
- Teamwork and collaboration hints
- Length optimization suggestions

## 📊 Job Description Analyzer

### Keyword Extraction
- Automatically detects technical keywords
- Identifies soft skills
- Extracts certifications and tools
- Supports 50+ common keywords

### Match Calculation
```
Match % = (Keywords Found in Resume / Total Keywords Extracted) × 100
```

### Recommendations
- **80-100%**: Excellent alignment
- **60-79%**: Good alignment, minor tweaks needed
- **40-59%**: Moderate alignment, targeted updates recommended
- **Below 40%**: Consider major resume revisions

## 🎯 Future Enhancements

### Phase 2
- [ ] Cloud sync across devices
- [ ] Multiple resume templates (Modern, Classic, Creative)
- [ ] Resume versioning and history
- [ ] Collaboration features (share for feedback)
- [ ] LinkedIn profile import

### Phase 3
- [ ] Advanced AI (GPT-powered suggestions)
- [ ] Real-time job market data
- [ ] Resume scoring against actual job postings
- [ ] Blind resume review (anonymized PDF)
- [ ] Interview preparation integration

### Phase 4
- [ ] Career analytics dashboard
- [ ] Job application tracking
- [ ] Network suggestions
- [ ] Salary negotiation guides
- [ ] Portfolio integration

## 📱 Customization

### Changing Theme Colors
Edit `main.dart`:
```dart
ColorScheme.fromSeed(
  seedColor: Colors.blue,  // Change this
  brightness: Brightness.light,
)
```

### Adding New Sections
1. Create model in `resume_model.dart`
2. Add provider method in `resume_provider.dart`
3. Create step widget in `resume_steps/`
4. Add to `ResumeBuilderScreen` page list

### Modifying ATS Rules
Edit `services/ats_validator.dart` to adjust validation thresholds and warning criteria.

## 🐛 Troubleshooting

### Export Not Working
- Ensure `printing` package is properly installed
- On Android, verify permissions in `AndroidManifest.xml`
- On iOS, update `Info.plist` with required permissions

### Layout Issues
- Clear Flutter build cache: `flutter clean`
- Rebuild: `flutter pub get && flutter run`
- Check device DPI settings

### Performance
- Use `flutter --profile` to analyze performance
- Consider reducing preview re-renders
- Optimize large resume data with pagination

## 📄 License

This project is provided as-is for educational and professional use.

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create feature branches
3. Submit pull requests with descriptions
4. Follow Dart style guide

## 📞 Support

For issues, questions, or suggestions:
- Open GitHub issues
- Check existing documentation
- Review example resumes in the app

---

**Built with ❤️ using Flutter**
