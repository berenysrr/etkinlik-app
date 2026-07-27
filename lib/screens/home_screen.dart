import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'event_detail_screen.dart';
import 'add_event_screen.dart';
import 'profile_screen.dart';
import 'calendar_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  bool _isOrganizer = false;
  bool _isLoadingRole = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'icon': '🌟'},
    {'name': 'Music', 'icon': '🎵'},
    {'name': 'Tech & Code', 'icon': '💻'},
    {'name': 'Art & Culture', 'icon': '🎨'},
    {'name': 'Workshops', 'icon': '🎓'},
    {'name': 'Food & Drinks', 'icon': '🍔'},
    {'name': 'Sports', 'icon': '⚽'},
  ];

  // High quality fallback posters matching event themes
  final List<String> _fallbackImages = [
    'https://picsum.photos/id/1082/800/500',
    'https://picsum.photos/id/0/800/500',
    'https://picsum.photos/id/1080/800/500',
    'https://picsum.photos/id/1060/800/500',
  ];


  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final userData = await _apiService.getCurrentUser();
      if (mounted) {
        setState(() {
          _isOrganizer = userData['is_organizer'] ?? false;
          _isLoadingRole = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isOrganizer = false;
          _isLoadingRole = false;
        });
      }
    }
  }

  String _formatImageUrl(dynamic rawImage, int index) {
    if (rawImage == null || rawImage.toString().trim().isEmpty) {
      return _getFallbackImage(index);
    }

    String url = rawImage.toString().trim();

    url = url.replaceAll('127.0.0.1', '10.0.2.2').replaceAll('localhost', '10.0.2.2');

    // 2. Eğer /media/ ile başlayan bağıntılı adrese Django portunu ekle
    if (url.startsWith('/media') || url.startsWith('media/')) {
      final cleanPath = url.startsWith('/') ? url : '/$url';
      url = 'http://10.0.2.2:8000$cleanPath';
    }

    return url;
  }

  String _getFallbackImage(int index) {
    return _fallbackImages[index % _fallbackImages.length];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: Colors.indigo,
          child: CustomScrollView(
            slivers: [
              // Top App Bar & Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Title, Calendar & Profile
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Explore Events 👋',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'What\'s Happening',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Calendar Button
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CalendarScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month_rounded,
                                    color: Colors.indigo,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Favorites Button
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FavoritesScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.redAccent,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Profile Button
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ProfileScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Colors.indigo,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.toLowerCase();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search title, city or venue...',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                            prefixIcon: const Icon(Icons.search_rounded, color: Colors.indigo),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Category Filter Horizontal List
                      SizedBox(
                        height: 42,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final isSelected = _selectedCategory == cat['name'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ChoiceChip(
                                label: Text('${cat['icon']} ${cat['name']}'),
                                selected: isSelected,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF334155),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                ),
                                selectedColor: Colors.indigo,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? Colors.indigo : Colors.grey.shade200,
                                  ),
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = cat['name']!;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Events List Stream / Future
              FutureBuilder<List<dynamic>>(
                future: _apiService.fetchEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting || _isLoadingRole) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.indigo),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off_rounded, color: Colors.red[300], size: 64),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to connect to backend',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_available_outlined, color: Colors.grey[400], size: 70),
                            const SizedBox(height: 16),
                            Text(
                              'No events found yet.',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Filter events by search query AND category
                  final rawEvents = snapshot.data!;
                  final events = rawEvents.where((e) {
                    final title = (e['title'] ?? '').toString().toLowerCase();
                    final location = (e['location'] ?? '').toString().toLowerCase();
                    final matchesSearch = title.contains(_searchQuery) || location.contains(_searchQuery);

                    bool matchesCategory = true;
                    if (_selectedCategory != 'All') {
                      final categoryDetailName = (e['category_detail']?['name'] ?? '').toString().toLowerCase();
                      final selectedCat = _selectedCategory.toLowerCase();
                      matchesCategory = categoryDetailName.contains(selectedCat) || selectedCat.contains(categoryDetailName);
                    }

                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (events.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No events matching "$_searchQuery"'
                              : 'No events found in "$_selectedCategory"',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ),
                    );
                  }


                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = events[index];
                          final imageUrl = _formatImageUrl(event['image'], index);
                          final price = event['price']?.toString() ?? '0.00';

                          final isFree = price == '0.00' || price == '0';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.withOpacity(0.07),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventDetailScreen(event: event),
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {});
                                  }
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Event Cover Image Stack with Badge Overlay
                                    Stack(
                                      children: [
                                        Image.network(
                                          imageUrl,
                                          height: 210,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 210,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.indigo.shade400, Colors.indigo.shade700],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.event_available_rounded, size: 54, color: Colors.white70),
                                                  const SizedBox(height: 8),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                                    child: Text(
                                                      event['title'] ?? 'Featured Event',
                                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                                      textAlign: TextAlign.center,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Gradient overlay for text contrast
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.4),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Category Badge Overlay (Top Left)
                                        if (event['category_detail']?['name'] != null)
                                          Positioned(
                                            top: 16,
                                            left: 16,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.6),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                event['category_detail']['name'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        // Price Badge Overlay
                                        Positioned(
                                          top: 16,
                                          right: 16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isFree ? Colors.green.shade600 : Colors.indigo.shade600,
                                              borderRadius: BorderRadius.circular(30),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              isFree ? 'FREE' : '\$$price',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Date Tag Pill Overlay
                                        Positioned(
                                          bottom: 16,
                                          left: 16,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.92),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.indigo),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${event['date'] ?? ''} • ${event['time'] ?? ''}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Event Content Information
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event['title'] ?? 'Untitled Event',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A),
                                              height: 1.25,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_rounded,
                                                size: 18,
                                                color: Colors.indigo.shade400,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  event['location'] ?? 'Venue TBA',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: events.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // Organizer Add Event Floating Action Button
      floatingActionButton: _isOrganizer
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddEventScreen(),
                  ),
                );
                if (result == true) {
                  setState(() {});
                }
              },
              backgroundColor: Colors.indigo.shade600,
              elevation: 6,
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              label: const Text(
                'Create Event',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            )
          : null,
    );
  }
}