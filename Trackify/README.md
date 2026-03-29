# 📊 Trackify — Monthly Expense Tracker



<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.41.2-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart" />
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android" />
  <img src="https://img.shields.io/badge/Storage-Hive-orange" />
  <img src="https://img.shields.io/badge/License-MIT-purple" />
</p>

> A fully offline Android expense tracker app built with Flutter.
> Track spending, set budgets, visualise trends — no internet required.

---

## ✨ Features

- 📊 **Dashboard** — Total expenses, pie chart, category breakdown with progress bars
- ➕ **Add Expense** — Amount, category, date picker, optional note
- 📋 **View Expenses** — Full list with delete functionality
- 📈 **Analytics** — Monthly trend chart + day-wise spending chart
- ⚙️ **Settings** — Dark mode, font size, salary & savings calculator
- 💰 **Budget Calculator** — Enter salary → auto calculates savings & spendable amount
- 🌙 **Dark Mode** — Full app dark mode support
- 🔤 **Font Size** — Small / Medium / Large options
- 💾 **Offline First** — All data saved locally using Hive database

---

## 📱 Screenshots

> Coming soon

---

## 🚀 Download

👉 [Download Latest APK](https://github.com/SubashImmareddy/Projects/releases/latest)

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter 3.41.2 | Cross-platform mobile framework |
| Dart 3.x | Programming language |
| Hive | Local offline database |
| Provider | State management |
| fl_chart | Pie & bar charts |
| intl | Date & number formatting |

---

## 📁 Project Structure
```
lib/
├── main.dart
├── models/
│   └── expense.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── add_expense_screen.dart
│   ├── view_expenses_screen.dart
│   ├── analytics_screen.dart
│   └── settings_screen.dart
├── services/
│   ├── expense_service.dart
│   ├── theme_service.dart
│   └── budget_service.dart
└── widgets/
    └── category_progress_bar.dart
```

---

## 🏃 Run Locally

**Prerequisites:**
- Flutter SDK 3.41.2+
- Android Studio + Android SDK
- Java JDK 17

**Steps:**
```bash
# Clone the repo
git clone https://github.com/SubashImmareddy/Projects.git

# Go to Trackify folder
cd Projects/Trackify

# Install dependencies
flutter pub get

# Run the app
flutter run

# Build release APK
flutter build apk --release
```

---

## 📦 Expense Categories

| Category | Colour |
|---|---|
| 🔴 Bills | #FF6B6B |
| 🟦 Shopping | #4ECDC4 |
| 🔵 Food | #45B7D1 |
| 🟢 Transport | #96CEB4 |
| 🟣 Miscellaneous | #DDA0DD |

---

## 💡 Budget Logic
```
Savings Amount   = Salary × (Savings % ÷ 100)
Spendable Amount = Salary - Savings Amount
Remaining Budget = Spendable Amount - Total Spent
```

---

## 🔮 Future Plans

- [ ] Export to CSV/PDF
- [ ] Recurring expenses
- [ ] Fingerprint lock
- [ ] Cloud backup
- [ ] Custom categories
- [ ] Multiple currencies

---

## 👨‍💻 Developer

**Subash Immareddy**
- GitHub: [@SubashImmareddy](https://github.com/SubashImmareddy)

---

## 📄 License

This project is licensed under the MIT License.
