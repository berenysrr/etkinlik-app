import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'event_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _favoriteEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteEvents();
  }

  // 💖 Favori Etkinlikleri Yükleme Metodu
  Future<void> _loadFavoriteEvents() async {
    try {
      final favIds = await _apiService.getFavorites(); // Telefon kasasındaki ID'ler
      final allEvents = await _apiService.fetchEvents(); // Backend'deki tüm etkinlikler

      // Sadece favori ID'lerine sahip olan etkinlikleri filtrele
      final filtered = allEvents.where((event) {
        final idStr = event['id']?.toString() ?? '';
        return favIds.contains(idStr);
      }).toList();

      if (mounted) {
        setState(() {
          _favoriteEvents = filtered;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🗑️ Favoriden Çıkarma Metodu
  Future<void> _removeFromFavorites(String eventId) async {
    await _apiService.toggleFavorite(eventId);
    _loadFavoriteEvents(); // Listeyi yenile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Favorites ❤️', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : _favoriteEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border_rounded, size: 70, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No favorite events saved yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _favoriteEvents.length,
                  itemBuilder: (context, index) {
                    final event = _favoriteEvents[index];
                    final imageUrl = event['image'] ?? 'https://picsum.photos/id/1082/800/500';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.indigo.shade50,
                              child: const Icon(Icons.event, color: Colors.indigo),
                            ),
                          ),
                        ),
                        title: Text(
                          event['title'] ?? 'Event',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${event['date']} • ${event['location']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                          onPressed: () => _removeFromFavorites(event['id'].toString()),
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(event: event),
                            ),
                          );
                          _loadFavoriteEvents(); // Detaydan dönünce listeyi tazele
                        },
                      ),
                    );
                  },
                ),
    );
  }
}