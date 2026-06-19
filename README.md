<h1 align="center">📝 Simplist</h1>

<p align="center">
  Simplify Tasks • Amplify Productivity • Stay Organized
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart" />
  <img src="https://img.shields.io/badge/Hive-Local%20Database-yellow" />
  <img src="https://img.shields.io/badge/Firebase-Cloud%20Sync-orange" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Windows-green" />
  <img src="https://img.shields.io/github/last-commit/ramanzenith/Simplist-To-Do-app" />
</p>

---

## 🚀 Overview

**Simplist** is a lightweight, offline-first, cross-platform task management application built with **Flutter**.  
It provides a clean, premium interface with a robust feature set, combining the speed of **Hive local storage** with the reliability of **Firebase Cloud Sync**.

Designed with a modular architecture and reusable components, Simplist is built for maintainability, speed, and seamless user experience.

---

## ✨ Features

- ➕ **Add & Edit Tasks:** Seamlessly create, edit, and organize your daily goals.
- 🗑 **Swipe-to-Delete (Slidable):** Quick and intuitive task management.
- ✅ **Categories & Priorities:** Tag tasks by category (Work, Personal, etc.) and prioritize them (High, Medium, Low) with visual indicators.
- 📅 **Due Dates & Recurring:** Set specific deadlines and choose to repeat tasks daily, weekly, or monthly.
- 🔔 **Smart Notifications:** Local push notifications scheduled automatically, including 30-minute advance reminders.
- 🌙 **Premium Dark Mode:** Auto-switching, meticulously crafted dark mode with a midnight blue-grey palette.
- 💾 **Offline-First Storage (Hive):** Instant load times and complete functionality even without an internet connection.
- ☁ **Cloud Sync (Firestore):** Start anonymously, then link a Google account anytime to securely sync your tasks across devices.
- ↕ **Advanced Sorting:** Sort tasks manually (drag & drop), by Priority, by Due Date, or alphabetically.
- 🟨 **Minimalist UI:** Clean, responsive, and clutter-free design.

---

## 🛠 Tech Stack

- **Framework:** Flutter & Dart
- **Local Database:** Hive (NoSQL)
- **Backend Services:** Firebase Authentication (Anonymous & Google), Cloud Firestore
- **Local Notifications:** `flutter_local_notifications`
- **Other Packages:** `flutter_slidable`, `intl`, `timezone`

---

## 📦 Download Builds

### 📱 Android APK
👉 https://github.com/ramanexc/Simplist-To-Do-app/releases/download/v1.0.0/Simplist.To-Do.App.apk  

### 🖥 Windows Version
👉 https://github.com/ramanexc/Simplist-To-Do-app/releases/download/v1.0.0/Simplist.To-Do.App.zip  

> Extract the ZIP file and run the `.exe`.

---

## 📂 Project Structure
```
Simplist-To-Do-app/
├── android/
├── windows/
├── assets/
├── lib/
│   ├── database/       # Hive box, Task model, data sync logic
│   ├── pages/          # Main UI screens (e.g., mainpage.dart)
│   ├── services/       # Firestore and Notification integration
│   ├── widgets/        # Reusable UI components (tiles, dialogs)
│   └── main.dart       # App entry point, theme & route config
├── pubspec.yaml
└── README.md
```
---

## 🧠 Architecture Highlights

- **Offline-First Approach:** Uses Hive as the single source of truth for the UI, ensuring zero loading spinners. Firestore quietly syncs in the background.
- **Anonymous-to-Authenticated Flow:** Users don't need to log in to use the app immediately. Data is saved anonymously and later safely merged when they choose to use Google Sign-In.
- **Theme-Aware Components:** All UI widgets dynamically adapt to the system's current dark/light mode preference using robust `ThemeData` variables.

---

## 🔮 Future Improvements

- 📊 Analytics Dashboard
- 🎨 Custom Themes & Color Pickers
- 🤝 Collaborative Task Sharing
- 🍏 iOS App Store Release

---

## 📄 License

MIT License © 2026 Ramandeep Singh
