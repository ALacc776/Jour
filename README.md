# DayLog - Quick Daily Logging

A fast, simple daily logging app built with SwiftUI. Log your day in seconds, not minutes.

## Features

### Core Functionality
- **Instant Input**: Open the app and start typing immediately - no buttons, no choices
- **Quick-Add Buttons**: One-tap logging for common activities (Coffee, Workout, Read, Meal)
- **Edit Entries**: Full editing support - fix typos, update content anytime
- **Today View**: See all today's entries in one place
- **Search**: Find any entry instantly by text content
- **Calendar View**: Browse and add entries by date
- **Streak Tracking**: Visual streak tracking with progress to milestones

### Design Philosophy
- **Speed First**: 5 seconds from open to saved entry
- **Zero Friction**: No category selection required, no mode switching
- **Auto-Save**: Type and go - entries save automatically
- **Clean UI**: Minimal, focused interface
- **Haptic Feedback**: Tactile confirmation for all actions

### Additional Features
- **Daily Reminders**: Customizable notification to maintain your streak
- **Activity Heat Map**: GitHub-style visualization of your logging activity
- **Enhanced Streak Display**: Motivational progress tracking with milestones
- **Local Storage**: All data stays on your device
- **Optional Encryption**: Toggle encryption for sensitive content
- **Data Export**: Export entries in JSON or text format
- **Privacy Policy**: Comprehensive privacy policy included

## App Store Requirements Compliance

### Privacy Requirements ✅
- [x] Privacy policy included
- [x] Data encryption implemented
- [x] User consent flow
- [x] Data export/deletion options
- [x] No third-party data sharing
- [x] Local-only data storage

### Content Requirements ✅
- [x] Appropriate for all ages
- [x] No offensive content filters needed
- [x] User-generated content guidelines
- [x] Data backup and restore functionality

### Functionality Requirements ✅
- [x] Offline capability
- [x] Data persistence
- [x] Export features (JSON, text, CSV)
- [x] Backup and restore
- [x] Error handling
- [x] Performance optimization

### Technical Requirements ✅
- [x] No crashes or broken functionality
- [x] Good performance
- [x] No memory leaks
- [x] Complete features
- [x] Unit tests included
- [x] UI tests included

## What Makes DayLog Different?

Unlike traditional journal apps, DayLog is designed for **speed and simplicity**:

- ❌ **No** complex entry forms
- ❌ **No** mandatory categories  
- ❌ **No** separate "create entry" button
- ✅ **Just** open and type
- ✅ **Auto-saves** as you go
- ✅ **Quick-add** buttons for instant logging

**Goal**: Log your day in 5 seconds or less.

## App Store Submission Checklist

### App Store Connect Setup
- [ ] App name: "DayLog"
- [x] Bundle ID: `alacc776.Jour`
- [x] Version: 1.0.0
- [x] Category: Productivity
- [x] Age rating: 4+ (All Ages)
- [x] Pricing: Free

### Required Assets
- [x] App icon (1024x1024)
- [x] Screenshots (iPhone and iPad)
- [x] App preview videos (optional)
- [x] Privacy policy HTML file
- [x] Terms of service (if applicable)

### App Store Review Guidelines Compliance
- [x] **Functionality**: Complete, functional app
- [x] **Design**: Professional, polished interface
- [x] **Content**: Appropriate for all ages
- [x] **Privacy**: Comprehensive privacy policy
- [x] **Legal**: Complies with all legal requirements
- [x] **Performance**: Optimized performance
- [x] **Accessibility**: Full accessibility support

## Technical Specifications

### Minimum Requirements
- **iOS**: 15.0+
- **Devices**: iPhone, iPad
- **Architecture**: arm64
- **Language**: Swift 5.0+
- **Framework**: SwiftUI

### Dependencies
- **SwiftUI**: Native iOS framework
- **Foundation**: Core functionality
- **CryptoKit**: Encryption support
- **Security**: Keychain integration

### Performance Metrics
- **Launch Time**: < 3 seconds
- **Memory Usage**: < 100 MB
- **Storage**: Minimal footprint
- **Battery**: Optimized for efficiency

## Testing

### Unit Tests
- `JournalManagerTests`: Tests data persistence and streak calculations
- `PrivacyManagerTests`: Tests encryption and privacy features
- `ErrorManagerTests`: Tests error handling

### UI Tests
- `JournalAppUITests`: Tests user interface interactions
- Navigation testing
- Entry creation testing
- Settings testing
- Accessibility testing

### Performance Tests
- Launch time measurement
- Memory usage monitoring
- Scrolling performance
- Data persistence performance

## Privacy Policy

The app includes a comprehensive privacy policy that covers:
- Data collection practices (minimal)
- Data storage (local only)
- Data encryption
- User rights
- Contact information

## Support

For support and questions:
- Email: support.and@proton.me
- In-app support through Menu

## Development

### Building the App
1. Open `Jour.xcodeproj` in Xcode
2. Select your development team
3. Build and run on simulator or device

### App Store Submission
1. Archive the app in Xcode
2. Upload to App Store Connect
3. Complete app information
4. Submit for review

### Code Quality
- **Documentation**: Comprehensive code documentation
- **Error Handling**: Robust error handling throughout
- **Performance**: Optimized for performance
- **Security**: Secure data handling
- **Accessibility**: Full accessibility support

## Version History

### Version 1.0.0
- Initial release
- Instant-input Today view
- Quick-add buttons for one-tap logging
- Full entry editing
- Search functionality
- Enhanced streak tracking with milestones
- Activity heat map visualization
- Daily reminder notifications
- Calendar view
- Local data storage with optional encryption

## License

This project is proprietary software. All rights reserved.

## Contact

For questions about this app or its development:
- Developer: andapple
- Email: support.and@proton.me

---

**Note**: DayLog is built for speed and simplicity. Your entries stay on your device and are never transmitted to external servers. The goal is to make daily logging so fast and easy that you actually do it every day.
