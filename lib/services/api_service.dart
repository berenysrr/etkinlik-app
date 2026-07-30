import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api'; // 🌐 Chrome / Web için
    }
    return 'http://10.0.2.2:8000/api'; // 📱 Android Emülatör için
  }


  // 1. Etkinlikleri Getirme Metodu
  Future<List<dynamic>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events/'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load events. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // 1b. Kategorileri Getirme Metodu
  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories/'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Get categories error: $e');
    }
  }


  // 2. Giriş Yapma Metodu (Login)
  Future<bool> login(String username, String password) async {
    try {
        // 1. Django'ya kullanıcı adı ve şifreyi gönder
      final response = await http.post(
        Uri.parse('$baseUrl/token/'),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // 3. Kayıt Olma Metodu (Register)
  Future<bool> register(
    String username,
    String email,
    String password,
    bool isOrganizer,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts/register/'),
        body: {
          'username': username,
          'email': email,
          'password': password,
          'is_organizer': isOrganizer.toString(),
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Register error: $e');
    }
  }

  // 4. Etkinlik Oluşturma Metodu
  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      print(
        'Gönderilen Token: $token',
      ); // Terminalde token var mı diye konsola yazdıralım

      final response = await http.post(
        Uri.parse('$baseUrl/events/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Bilet burada ekleniyor
        },
        body: json.encode(eventData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Django Hata Kodu: ${response.statusCode}');
        print('Django Hata Detayı: ${response.body}');
        return false;
      }
    } catch (e) {
      throw Exception('Create event error: $e');
    }
  }

  // 5. YENİ: Geçerli Kullanıcının Bilgilerini Getirme Metodu
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token'); // Cüzdandan bileti al

      final response = await http.get(
        Uri.parse(
          '$baseUrl/accounts/me/',
        ), // Yeni oluşturduğumuz adrese gidiyoruz
        headers: {
          'Authorization': 'Bearer $token', // Güvenliğe bileti gösteriyoruz
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // JSON paketini Flutter'a teslim et
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Get user error: $e');
    }
  }

  // 6. YENİ: Etkinliğe Katılma Metodu
  Future<bool> joinEvent(int eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.post(
        Uri.parse('$baseUrl/register-event/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'event': eventId}),
      );

      if (response.statusCode == 201) {
        return true; // Katılım başarılı!
      } else {
        print('Join error: ${response.body}');
        return false;
      }
    } catch (e) {
      throw Exception('Join event error: $e');
    }
  }

  // 7. YENİ: Kullanıcının Katıldığı Etkinlikleri Getirme Metodu
  Future<List<dynamic>> getMyJoinedEvents() async {
    try {
      // 1. Cüzdandan (SharedPreferences) kullanıcının JWT erişim biletini alıyoruz
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      // 2. Backend'e biletimizle birlikte GET isteği atıyoruz
      final response = await http.get(
        Uri.parse('$baseUrl/my-joined-events/'),
        headers: {
          'Authorization':
              'Bearer $token', // Güvenlik kapısına biletimizi gösteriyoruz
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load joined events');
      }
    } catch (e) {
      throw Exception('Get joined events error: $e');
    }
  }

  // 8. YENİ: Organizatörün Etkinliği Silme Metodu
  Future<bool> deleteEvent(int eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.delete(
        Uri.parse('$baseUrl/events/$eventId/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Delete event error: $e');
    }
  }

  // 9. YENİ: Katılımcının Etkinlik Katılımını İptal Etme Metodu
  Future<bool> leaveEvent(int eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.delete(
        Uri.parse('$baseUrl/unregister-event/$eventId/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Leave event error: $e');
    }
  }
    // 💖 1. Favori Etkinlik ID Listesini Getir
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorite_events') ?? [];
  }

  // 💖 2. Etkinliği Favorilere Ekle veya Çıkar (Toggle)
  Future<bool> toggleFavorite(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorite_events') ?? [];

    bool isFav;
    if (favorites.contains(eventId)) {
      favorites.remove(eventId); // Zaten favorideyse çıkar
      isFav = false;
    } else {
      favorites.add(eventId); // Favoride değilse ekle
      isFav = true;
    }

    await prefs.setStringList('favorite_events', favorites);
    return isFav; // Yeni durumu döndür (true: eklendi, false: çıkarıldı)
  }

  // 💖 3. Bir Etkinliğin Favori Olup Olmadığını Kontrol Et
  Future<bool> isFavorite(String eventId) async {
    final favorites = await getFavorites();
    return favorites.contains(eventId);
  }
}
