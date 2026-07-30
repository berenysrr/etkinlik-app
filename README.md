# 🎟️ Etkinlik Takip & Dijital Bilet Uygulaması (Event Tracker App)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Django](https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

Modern, şık ve tam teşekküllü bir **Etkinlik Takip ve QR Kodlu Dijital Bilet Platformu**. Kullanıcılar şehirlerindeki veya ilgi alanlarındaki etkinlikleri keşfedebilir, tek tıkla katılım sağlayıp kişisel **QR Kodlu Dijital Biletlerini** alabilir, takvimlerine aktarabilir ve favorilerine ekleyebilirler. 

Ayrıca organizatörler kendi özel etkinliklerini oluşturup yönetebilirler.

---

## ✨ Öne Çıkan Özellikler

- **🔐 Rol Tabanlı Kimlik Doğrulama (JWT Auth):**
  - **Organizatör (Organizer):** Yeni etkinlik ekleme ve silme yetkisi.
  - **Katılımcı (Attendee):** Etkinlik keşfi, katılım ve bilet alma yetkisi.
- **🎟️ QR Kodlu Dijital Bilet Sistemi:** Katılınan etkinlik için anında şifreli ve okutulabilir QR kodlu dijital bilet üretimi (`qr_flutter`).
- **❤️ Favori Etkinlikler (Wishlist):** `SharedPreferences` ile internetsiz ve hızlı çalışan favoriler modülü.
- **📅 İnteraktif Takvim:** `table_calendar` ile etkinlik günlerinin noktalı gösterimi ve güne göre filtreleme.
- **📆 Cihaz Takvimine Aktarma (Add to Calendar):** Etkinlik detaylarını tek tıkla cihazın yerel **Google / Apple Takvim** uygulamasına kaydetme (`url_launcher`).
- **🎨 Glassmorphic Modern UI:** Gece moru gradyan zeminler, canlı kategori çipleri, buzlu cam efektleri ve akıllı durum butonları.
- **🔍 Çift Filtreli Canlı Arama:** Arama metni ve kategori seçimini anlık birleştirerek süzme.

---

## 🛠️ Teknoloji Yığını (Tech Stack)

### Frontend (Mobil Uygulama)
- **Framework:** Flutter (Dart)
- **State Management:** StatefulWidget / Reactive State
- **HTTP Client:** `http`
- **Local Storage:** `shared_preferences`
- **UI & Libraries:** `qr_flutter`, `table_calendar`, `url_launcher`

### Backend (REST API Sunucusu)
- **Framework:** Python / Django 5.x
- **API Tooling:** Django REST Framework (DRF)
- **Authentication:** `djangorestframework-simplejwt` (JWT Access & Refresh Token)
- **Database:** SQLite3

---

## 📁 Proje Klasör Yapısı

```text
etkinlik_app/
├── backend/                  # Django REST Framework Sunucusu
│   ├── accounts/             # Kullanıcı kayıt, giriş ve profil yönetimi
│   ├── events/               # Etkinlikler, kategoriler ve kayıt masası
│   ├── etkinlik_takip/       # Django ana ayarlar & URL yönlendirmeleri
│   └── manage.py
└── frontend/                 # Flutter Mobil Uygulaması
    ├── lib/
    │   ├── main.dart         # Başlangıç noktası & tema
    │   ├── screens/          # Uygulama ekranları (Home, Detail, Favorites, Calendar, Login vb.)
    │   └── services/         # ApiService (Backend HTTP iletişim kuryesi)
    └── pubspec.yaml
```

---

## 🚀 Kurulum ve Çalıştırma Kılavuzu

### 1. Backend (Django REST API) Kurulumu

```bash
# Backend klasörüne gidin
cd backend

# Sanal ortam (venv) oluşturun ve aktifleştirin
python -m venv .venv
# Windows için:
.venv\Scripts\activate

# Gerekli paketleri yükleyin
pip install django djangorestframework djangorestframework-simplejwt django-cors-headers pillow

# Veritabanı göçlerini uygulayın
python manage.py migrate

# Sunucuyu başlatın
python manage.py runserver 0.0.0.0:8000
```

---

### 2. Frontend (Flutter) Kurulumu

```bash
# Frontend klasörüne gidin
cd frontend

# Bağımlılıkları indirin
flutter pub get

# Android Emülatör veya cihazda çalıştırın
flutter run
```

---

## 📡 API Uç Noktaları (Endpoints Summary)

| Metot | Uç Nokta | Açıklama | Yetki |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/accounts/register/` | Yeni kullanıcı kaydı (`is_organizer` seçeneği ile) | Herkese Açık |
| `POST` | `/api/token/` | Giriş yapıp JWT Token alma | Herkese Açık |
| `GET` | `/api/accounts/me/` | Giriş yapan kullanıcının profilini getirme | Biletli (Token) |
| `GET` | `/api/events/` | Tüm etkinlikleri listeleme | Herkese Açık |
| `POST` | `/api/events/` | Yeni etkinlik oluşturma | Organizatör |
| `DELETE` | `/api/events/<id>/` | Etkinliği silme | Organizatör |
| `POST` | `/api/register-event/` | Etkinliğe katılma | Biletli (Token) |
| `GET` | `/api/my-joined-events/` | Katılınan etkinlikleri getirme | Biletli (Token) |
| `GET` | `/api/categories/` | Canlı kategorileri getirme | Herkese Açık |

---

## 📜 Lisans

Bu proje açık kaynaklı olup eğitim ve geliştirme amacıyla tasarlanmıştır.
