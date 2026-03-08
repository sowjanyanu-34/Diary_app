# Echo Diary App

## 1. Introduction

Echo Diary App is a Flutter-based Android application that allows users to securely record and manage their daily diary entries. The application uses Firebase Authentication for secure user login and Cloud Firestore for storing diary notes. Users can write, edit, and search diary entries by date, month, year, or tags.

## 2. Features

1. User registration using email and password with password validation rules.
2. Secure login using Firebase Authentication.
3. Password reset option through email.
4. Create and edit daily diary entries.
5. Search diary entries by:

   * Specific date
   * Month or year
   * Tags (Special, Important, Bad News)
6. Diary entries cannot be deleted, only edited.
7. Navigation bar with Home, Search, and Logout options.

## 3. Technologies Used

1. Flutter
2. Firebase Authentication
3. Cloud Firestore
4. Material UI

## 4. Project Structure

```
lib/
 ├── models/
 ├── screens/
 ├── services/
 ├── widgets/
 └── main.dart
```

## 5. How to Run the Project

1. Install Flutter and Android Studio.
2. Set up an Android emulator (Pixel 7, API 36).
3. Clone the repository:
   git clone https://github.com/syeda-mizba/EchoDiary.git
4. Navigate to the project folder:
   cd EchoDiary
5. Install dependencies:
   flutter pub get
6. Run the application:
   flutter run

## 6. How to Deploy the App (APK)

1. Open the project in Android Studio or VS Code.
2. Connect an Android device or start an emulator.
3. Run the command:
   flutter build apk
4. The generated APK file will be available in:
   build/app/outputs/flutter-apk/
5. Install the APK on any Android device.

## 7. Author

Echo Diary Marathon Team
