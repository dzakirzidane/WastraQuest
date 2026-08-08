# RUMUSAN MASALAH
## Aplikasi Game Quiz Pakaian Adat Nusantara (Busana Nusantara)

---

## 1. LATAR BELAKANG MASALAH

Indonesia memiliki kekayaan budaya yang sangat beragam, salah satunya adalah pakaian adat (busana tradisional) dari berbagai daerah. Setiap provinsi memiliki ciri khas pakaian adat yang mencerminkan identitas budaya dan filosofi masyarakatnya. Namun, seiring perkembangan zaman dan modernisasi, pengetahuan generasi muda tentang pakaian adat Nusantara mulai memudar.

Di era digital saat ini, pemanfaatan teknologi dalam pendidikan dan pelestarian budaya menjadi sangat penting. Game edukasi berbasis mobile dapat menjadi solusi efektif untuk meningkatkan minat dan pengetahuan masyarakat, khususnya generasi muda, terhadap kekayaan budaya Indonesia.

Berdasarkan permasalahan tersebut, diperlukan sebuah aplikasi game quiz interaktif yang dapat memberikan pembelajaran tentang pakaian adat Nusantara dengan cara yang menarik dan menyenangkan, serta dilengkapi dengan sistem yang menantang untuk meningkatkan motivasi pengguna dalam belajar.

---

## 2. IDENTIFIKASI MASALAH

Dari latar belakang di atas, dapat diidentifikasi beberapa masalah sebagai berikut:

1. **Kurangnya media pembelajaran interaktif** tentang pakaian adat Nusantara yang menarik bagi generasi muda
2. **Minimnya pemanfaatan teknologi mobile** dalam edukasi budaya Indonesia
3. **Tidak adanya sistem evaluasi pengetahuan** yang efektif dan menyenangkan tentang busana tradisional
4. **Perlunya metode gamifikasi** untuk meningkatkan motivasi belajar tentang budaya
5. **Kesulitan mengakses informasi** pakaian adat yang komprehensif dan terstruktur
6. **Tidak adanya tingkat kesulitan adaptif** yang menyesuaikan dengan kemampuan pengguna
7. **Kurangnya feedback sistem** yang memotivasi pengguna untuk terus belajar

---

## 3. BATASAN MASALAH

Agar penelitian ini lebih fokus dan terarah, maka perlu adanya batasan masalah sebagai berikut:

1. Aplikasi dikembangkan menggunakan **Flutter framework** dengan bahasa pemrograman **Dart**
2. Platform target adalah **Android dan iOS** (cross-platform mobile)
3. Konten quiz terbatas pada **pakaian adat Indonesia** dari berbagai provinsi
4. Sistem quiz menggunakan **model pilihan ganda** dengan 4 opsi jawaban
5. Implementasi mencakup **3 tingkat kesulitan**: Easy (5 soal), Medium (10 soal), dan Hard (15 soal)
6. Sistem nyawa/lives bervariasi: Easy (5 nyawa), Medium (3 nyawa), Hard (1 nyawa)
7. Manajemen state menggunakan **Riverpod state management**
8. Penyimpanan data lokal menggunakan **SharedPreferences**
9. Soal quiz dimuat dari file **JSON** lokal
10. Tidak mencakup fitur multiplayer atau online leaderboard

---

## 4. RUMUSAN MASALAH

Berdasarkan identifikasi dan batasan masalah di atas, maka rumusan masalah dalam penelitian ini adalah:

### 4.1 Masalah Umum
**"Bagaimana merancang dan mengembangkan aplikasi game quiz edukasi pakaian adat Nusantara berbasis mobile yang interaktif, adaptif, dan mampu meningkatkan pengetahuan pengguna tentang budaya Indonesia?"**

### 4.2 Masalah Khusus

1. **Bagaimana merancang antarmuka pengguna (UI/UX)** yang menarik dan intuitif untuk aplikasi game quiz pakaian adat Nusantara?

2. **Bagaimana mengimplementasikan sistem tingkat kesulitan (_difficulty level_)** yang adaptif dengan jumlah soal berbeda (Easy: 5 soal, Medium: 10 soal, Hard: 15 soal)?

3. **Bagaimana mengimplementasikan sistem nyawa (_lives system_)** yang berbeda untuk setiap tingkat kesulitan guna meningkatkan tantangan permainan?

4. **Bagaimana merancang algoritma randomisasi soal** untuk memastikan setiap sesi permainan memberikan pengalaman yang berbeda?

5. **Bagaimana mengimplementasikan sistem penyimpanan skor terbaik (_best score persistence_)** menggunakan local storage untuk setiap tingkat kesulitan?

6. **Bagaimana merancang struktur data dan model** untuk menyimpan dan mengelola data pertanyaan quiz dari file JSON?

7. **Bagaimana mengimplementasikan manajemen state** yang efisien untuk mengelola alur permainan quiz menggunakan Flutter Riverpod?

8. **Bagaimana merancang sistem skoring** yang adil dan memotivasi pengguna untuk meningkatkan pengetahuan mereka?

9. **Bagaimana mengimplementasikan navigasi antar halaman** (splash screen, difficulty selection, quiz screen, result screen) yang smooth dan responsif?

10. **Bagaimana mengevaluasi efektivitas aplikasi** dalam meningkatkan pengetahuan pengguna tentang pakaian adat Nusantara?

---

## 5. TUJUAN PENELITIAN

Berdasarkan rumusan masalah di atas, tujuan penelitian ini adalah:

### 5.1 Tujuan Umum
Mengembangkan aplikasi game quiz edukasi pakaian adat Nusantara berbasis mobile yang interaktif, adaptif, dan efektif untuk meningkatkan pengetahuan pengguna tentang budaya Indonesia.

### 5.2 Tujuan Khusus

1. Merancang dan mengimplementasikan antarmuka pengguna yang menarik dengan tema Material 3 (dark navy dan gold)
2. Mengimplementasikan sistem tingkat kesulitan adaptif dengan jumlah soal yang berbeda
3. Mengimplementasikan sistem nyawa yang berbeda untuk setiap tingkat kesulitan
4. Merancang dan mengimplementasikan algoritma randomisasi soal menggunakan shuffle algorithm
5. Mengimplementasikan penyimpanan skor terbaik menggunakan SharedPreferences
6. Merancang struktur data Question model dan sistem loading dari JSON
7. Mengimplementasikan state management menggunakan Flutter Riverpod (QuizState, QuizNotifier)
8. Merancang sistem skoring 20 poin per jawaban benar
9. Mengimplementasikan navigasi menggunakan GoRouter
10. Melakukan pengujian dan evaluasi aplikasi

---

## 6. MANFAAT PENELITIAN

### 6.1 Manfaat Teoritis
1. Memberikan kontribusi pada pengembangan game edukasi berbasis mobile untuk pelestarian budaya
2. Memberikan referensi implementasi Flutter dengan Riverpod state management
3. Memberikan kajian tentang penerapan gamifikasi dalam pembelajaran budaya

### 6.2 Manfaat Praktis

#### a. Bagi Pengguna
- Mendapatkan media pembelajaran interaktif tentang pakaian adat Nusantara
- Meningkatkan pengetahuan budaya Indonesia dengan cara yang menyenangkan
- Memiliki akses mudah ke informasi pakaian adat dari berbagai provinsi

#### b. Bagi Pendidik
- Memiliki tools tambahan untuk pembelajaran budaya di sekolah
- Dapat menggunakan aplikasi sebagai media evaluasi pengetahuan siswa

#### c. Bagi Pengembang
- Mendapatkan referensi implementasi Flutter untuk game quiz
- Memahami penerapan state management dengan Riverpod
- Memahami implementasi lives system dan difficulty levels

#### d. Bagi Masyarakat
- Meningkatkan kesadaran tentang pentingnya pelestarian budaya
- Mendorong penggunaan teknologi untuk edukasi budaya

---

## 7. SISTEMATIKA PENULISAN (Usulan)

### BAB I: PENDAHULUAN
- A. Latar Belakang Masalah
- B. Identifikasi Masalah
- C. Batasan Masalah
- D. Rumusan Masalah
- E. Tujuan Penelitian
- F. Manfaat Penelitian
- G. Sistematika Penulisan

### BAB II: LANDASAN TEORI
- A. Game Edukasi
- B. Gamifikasi dalam Pembelajaran
- C. Flutter Framework
- D. Dart Programming Language
- E. State Management (Riverpod)
- F. Local Storage (SharedPreferences)
- G. Model-View-Controller (MVC) Pattern
- H. JSON Data Format
- I. Algoritma Randomisasi (Shuffle Algorithm)
- J. User Interface/User Experience (UI/UX)

### BAB III: METODOLOGI PENELITIAN
- A. Metode Penelitian
- B. Teknik Pengumpulan Data
- C. Analisis Kebutuhan Sistem
- D. Perancangan Sistem
  - Use Case Diagram
  - Activity Diagram
  - Flowchart
  - Class Diagram
  - Perancangan Database (JSON Structure)
  - Perancangan UI/UX
- E. Implementasi Sistem
- F. Pengujian Sistem

### BAB IV: HASIL DAN PEMBAHASAN
- A. Implementasi Aplikasi
  - Implementasi UI/UX
  - Implementasi Model Data
  - Implementasi State Management
  - Implementasi Lives System
  - Implementasi Difficulty Levels
  - Implementasi Randomisasi Soal
  - Implementasi Scoring System
  - Implementasi Local Storage
- B. Pengujian Aplikasi
  - Functional Testing
  - Usability Testing
  - Performance Testing
- C. Analisis Hasil

### BAB V: PENUTUP
- A. Kesimpulan
- B. Saran

---

## 8. FITUR-FITUR UTAMA APLIKASI

Berikut adalah fitur-fitur utama yang diimplementasikan dalam aplikasi:

### 8.1 Fitur Gameplay
- ✅ **Splash Screen** dengan auto-navigation
- ✅ **Profile Setup** untuk personalisasi pengguna
- ✅ **Difficulty Selection** (Easy/Medium/Hard)
- ✅ **Lives System** berbasis difficulty
- ✅ **Question Randomization** untuk variasi permainan
- ✅ **Multiple Choice Quiz** dengan 4 opsi
- ✅ **Real-time Feedback** pada jawaban
- ✅ **Score Tracking** dengan sistem poin
- ✅ **Best Score Persistence** per difficulty level
- ✅ **Result Screen** dengan statistik detail

### 8.2 Fitur Teknis
- ✅ **State Management** dengan Riverpod
- ✅ **Local Storage** dengan SharedPreferences
- ✅ **JSON Data Loading** untuk soal quiz
- ✅ **Routing** dengan GoRouter
- ✅ **Material 3 Design** dengan custom theme
- ✅ **Responsive UI** untuk berbagai ukuran layar
- ✅ **Smooth Animations** dan transitions
- ✅ **Error Handling** yang robust

### 8.3 Fitur Audio (Jika Diimplementasikan)
- 🔊 **Background Music**
- 🔊 **Sound Effects** (correct/wrong answer)
- 🔊 **Audio Focus Management** (Android)

---

## 9. CATATAN TAMBAHAN

Dokumen ini merupakan rumusan masalah awal yang dapat dikembangkan lebih lanjut sesuai dengan kebutuhan penulisan ilmiah. Beberapa aspek yang dapat ditambahkan:

1. **Literature Review** terkait game edukasi budaya
2. **Metodologi penelitian** yang lebih detail (R&D, prototyping, dll)
3. **Instrumen penelitian** (kuesioner, wawancara)
4. **Populasi dan sampel** untuk pengujian aplikasi
5. **Teknik analisis data** (kuantitatif/kualitatif)
6. **Referensi jurnal** dan buku yang relevan

---

**Disusun untuk:** Penulisan Ilmiah/Skripsi/Tugas Akhir  
**Topik:** Pengembangan Aplikasi Game Quiz Pakaian Adat Nusantara  
**Platform:** Flutter (Cross-Platform Mobile)  
**Tahun:** 2026
