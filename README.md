# 🏍️ Tankly

> A premium, offline-first vehicle management dashboard built with Flutter.

Tankly is a commercial-grade mobile application designed to help riders and drivers track their fuel efficiency, log maintenance records, and store critical vehicle documents in a secure, digital glovebox. Built with a focus on data integrity, offline reliability, and fluid UX.

---

## ✨ Features

* **Advanced Fuel Analytics:** Accurately calculates true fuel efficiency (km/L) by intelligently handling partial vs. full tank fill-ups.
* **Maintenance & Service Logs:** Track costs and odometer readings for oil changes, chain lubes, and general service intervals.
* **Smart Reminders:** Set distance-based (odometer) or date-based alerts for upcoming service or insurance renewals.
* **Digital Glovebox:** Securely store and view high-resolution local copies of your Registration (RC) and Insurance documents.
* **Premium UI/UX:** Features a custom "Slate" theme, system-aware Dark Mode, custom empty-state illustrations, and fluid list cascade animations.
* **100% Offline-First:** Powered by a robust SQLite architecture, ensuring zero latency and complete privacy for the user.

## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)
* **Local Database:** `sqflite` (Relational data modeling)
* **State Management:** Native `ValueNotifier` & `StatefulWidget` (Optimized for lightweight utility)
* **Motion Design:** `flutter_animate`
* **Typography:** `google_fonts` (Outfit)

## 📸 Screenshots

*(Pro-tip: Once you push to GitHub, take 3 screenshots of your app running on an emulator: The Dashboard, The Add Fuel Modal, and the Bike Profile. Upload them to an `assets` folder in your repo and link them here!)*

|<img src="assets/dashboard.png" width="250"> | <img src="assets/add_fuel.png" width="250"> | <img src="assets/profile.png" width="250"> |
|:---:|:---:|:---:|
| **Rich Dashboard** | **Smart Logging** | **Digital Glovebox** |

## 🚀 Getting Started

To run this project locally:

1. Clone the repository:
   ```bash
   git clone [https://github.com/yourusername/tankly.git](https://github.com/yourusername/tankly.git)