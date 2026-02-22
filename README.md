# Whale-Chat 🐋

Whale-Chat is a modern, full-featured messaging application built with **Flutter** and **Firebase**. It provides a seamless communication experience with real-time messaging, status updates, and robust user authentication.

---

## ✨ Key Features

- **Real-time Messaging**: Instant text and image sharing with emoji support.
- **Status Stories**: Share image or text-based statuses that disappear after 24 hours.
- **Smart Notifications**: Real-time push notifications for messages and updates using Firebase Cloud Messaging.
- **User Search**: Easily find and connect with other users within the app.
- **Secure Authentication**: Complete auth flow including Signup, Login, Password Reset, and Email Verification.
- **Cloud-Powered Backend**: Utilizes Firebase Cloud Functions for secure server-side logic and data integrity.

---

## 🛠 Tech Stack

- **Frontend**: [Flutter](https://flutter.dev/) (Dart)
- **Backend**: [Firebase](https://firebase.google.com/)
  - **Authentication**: Firebase Auth
  - **Database**: Cloud Firestore
  - **Storage**: Firebase Storage (for media)
  - **Server-side Logic**: Cloud Functions for Firebase
  - **Messaging**: Firebase Cloud Messaging (FCM)
- **Architecture**: MVVM (Model-View-ViewModel) with the Repository pattern for clean code separation.
- **State Management**: Provider / ChangeNotifier.

---

## 📂 Project Structure

```text
lib/
├── data/           # Repositories, Models, and Services
├── view/           # Screens and UI Components
│   └── app/screens # Modular feature screens (Chat, Status, Search, etc.)
├── view_model/     # Business logic and UI state (ChangeNotifiers)
└── theme/          # Custom styling and color schemes
functions/          # Node.js Cloud Functions source code
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed and configured.
- A Firebase project setup at [Firebase Console](https://console.firebase.google.com/).

### Installation

1.  **Clone the repository**:

    ```bash
    git clone https://github.com/AhmedHelmy18/Whale-Chat.git
    cd Whale-Chat
    ```

2.  **Install dependencies**:

    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**:
    - Follow the [FlutterFire CLI guide](https://firebase.google.com/docs/flutter/setup?platform=ios) to configure your project.
    - Download your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in the appropriate directories if not using the CLI.

4.  **Run the app**:
    ```bash
    flutter run
    ```

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
