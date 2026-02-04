# 🍔 Food Order App

**Food Order App** adalah aplikasi mobile pemesanan makanan yang dibuat dengan **Flutter**.  
Aplikasi ini memungkinkan pengguna untuk melihat daftar makanan, menambahkannya ke keranjang, dan melakukan pemesanan dengan mudah. Proyek ini juga dirancang sebagai starter project Flutter untuk memperluas fitur lebih jauh.

📌 Repo: https://github.com/Figo04/food_order_app

---

## 📌 Fitur Utama

> ⚠️ *Sesuaikan daftar fitur ini dengan fitur yang sudah kamu implementasikan*

- 📜 Daftar menu makanan 📋  
- 🛒 Tambah/menghapus item di keranjang  
- 🔍 Pencarian makanan berdasarkan nama  
- 📊 Total harga pesanan  
- 🔔 Notifikasi pesanan (opsional)  
- ⚙️ Otentikasi pengguna (Email/Password)  
- 💾 Penyimpanan data dengan Firebase / Local DB (opsional)

---

## 📁 Struktur Folder

food_order_app/
├── android/
├── ios/
├── lib/
│ ├── models/
│ ├── screens/
│ ├── widgets/
│ ├── services/
│ └── main.dart
├── test/
├── web/
├── pubspec.yaml
└── README.md


---

## 🚀 📦 Teknologi & Dependensi

Aplikasi ini dibuat dengan:

- 🧰 **Flutter** – UI framework dengan Dart  
- 📦 Flutter Packages (tambahkan paket yang digunakan)  
  - `provider` / `bloc` / `riverpod` – state management  
  - `http` / `dio` – HTTP requests  
  - `firebase_auth` (jika menggunakan Firebase Auth)  
  - `cloud_firestore` (jika menggunakan Firestore)  
  - `shared_preferences` / `sqflite` – penyimpanan lokal

Contoh di `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  http: ^0.14.0
  flutter_svg: ^1.1.0
