import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isJoined = false;
  bool _isFavorite = false; // Etkinlik favorilerde mi?

  @override
  void initState() {
    super.initState();
    _checkIfJoined();
    _checkIfFavorite(); // 💖 Favori kontrolü
  }

  Future<void> _checkIfFavorite() async {
    final eventId = widget.event['id']?.toString() ?? '';
    final isFav = await _apiService.isFavorite(eventId);
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _toggleFavorite() async {
    final eventId = widget.event['id']?.toString() ?? '';
    final isFav = await _apiService.toggleFavorite(eventId);
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _checkIfJoined() async {
    try {
      final joinedEvents = await _apiService.getMyJoinedEvents();
      final currentEventId = widget.event['id']?.toString();

      final isAlreadyJoined = joinedEvents.any((item) {
        final itemEventId =
            (item['id'] ?? item['event']?['id'] ?? item['event'])?.toString();
        return itemEventId == currentEventId;
      });

      if (mounted) {
        setState(() {
          _isJoined = isAlreadyJoined;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleDeleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text(
          'Are you sure you want to permanently delete this event?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final eventId = widget.event['id'];
      final success = await _apiService.deleteEvent(eventId);
      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete event.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleJoinEvent() async {
    setState(() => _isLoading = true);
    final eventId = widget.event['id'];

    if (eventId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Event ID not found!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await _apiService.joinEvent(eventId);
    setState(() => _isLoading = false);

    if (mounted) {
      // Başarılı kaydolunduysa VEYA zaten önceden kaydolunmuşsa QR biletini aç ve butonu yeşil yap!
      setState(() => _isJoined = true);
      _showTicketModal(context);
    }
  }

  // 🎟️ QR Bilet Modalını Açan Metot
  void _showTicketModal(BuildContext context) {
    final eventId = widget.event['id'];
    final eventTitle = widget.event['title'] ?? 'Event Ticket';
    final ticketData = "ETKINLIK-APP | EVENT_ID:$eventId | TICKET_VALIDATED";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Icon(
              Icons.confirmation_number_rounded,
              color: Colors.indigo,
              size: 44,
            ),
            const SizedBox(height: 8),
            Text(
              eventTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 🌟 QR KOD BURADA ÇİZİLİYOR
            QrImageView(
              data: ticketData,
              version: QrVersions.auto,
              size: 220.0,
              foregroundColor: const Color(0xFF0F172A),
            ),

            const SizedBox(height: 16),
            Text(
              'Ticket ID: #TCK-$eventId-2026',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Show this QR code at the event entrance for entry.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 📅 Telefon Takvimine Aktarma Fonksiyonu
  Future<void> _addToPhoneCalendar() async {
    try {
      final title = Uri.encodeComponent(widget.event['title'] ?? 'Event');
      final description = Uri.encodeComponent(widget.event['description'] ?? '');
      final location = Uri.encodeComponent(widget.event['location'] ?? '');
      final dateStr = widget.event['date'] ?? '';
      final timeStr = (widget.event['time'] ?? '00:00:00').replaceAll(':', '');

      // Google Calendar URL formatı: YYYYMMDDTHHmmss
      final dateFormatted = dateStr.replaceAll('-', ''); // 2026-08-18 → 20260818
      final startFormatted = '${dateFormatted}T${timeStr.substring(0, 6)}';
      // Bitiş saati: 2 saat sonra
      final startDate = DateTime.parse('${dateStr}T${widget.event['time'] ?? '00:00:00'}');
      final endDate = startDate.add(const Duration(hours: 2));
      final endDateStr = endDate.toIso8601String().replaceAll('-', '').replaceAll(':', '').substring(0, 15);

      // 🌟 Google Calendar URL'i oluşturuyoruz
      final calendarUrl =
          'https://www.google.com/calendar/render?action=TEMPLATE'
          '&text=$title'
          '&dates=$startFormatted/$endDateStr'
          '&details=$description'
          '&location=$location';

      final uri = Uri.parse(calendarUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Calendar açılamadı.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatImageUrl(dynamic rawImage) {
    if (rawImage == null || rawImage.toString().trim().isEmpty) {
      return 'https://picsum.photos/id/1082/800/500';
    }
    String url = rawImage.toString().trim();
    url = url
        .replaceAll('127.0.0.1', '10.0.2.2')
        .replaceAll('localhost', '10.0.2.2');
    if (url.startsWith('/media') || url.startsWith('media/')) {
      final cleanPath = url.startsWith('/') ? url : '/$url';
      url = 'http://10.0.2.2:8000$cleanPath';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _formatImageUrl(widget.event['image']);
    final price = widget.event['price']?.toString() ?? '0.00';
    final isFree = price == '0.00' || price == '0';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            slivers: [
              // Hero Image Header App Bar
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: Colors.indigo.shade900,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.indigo.shade800,
                          child: const Icon(
                            Icons.event,
                            size: 100,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorite ? Colors.redAccent : Colors.white,
                      size: 28,
                    ),
                    tooltip: 'Favorite',
                    onPressed: _toggleFavorite,
                  ),
                  // 🗑️ Silme Butonu
                  IconButton(
                    icon: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                    tooltip: 'Delete Event',
                    onPressed: _isLoading ? null : _handleDeleteEvent,
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Event Detail Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Status Tag Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '📍 Event Venue',
                              style: TextStyle(
                                color: Colors.indigo.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isFree
                                  ? Colors.green.shade50
                                  : Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isFree ? 'FREE ENTRY' : '\$$price',
                              style: TextStyle(
                                color: isFree
                                    ? Colors.green.shade700
                                    : Colors.indigo.shade700,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title
                      Text(
                        widget.event['title'] ?? 'Untitled Event',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info Grid (Date, Time, Location, Quota)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoTile(
                              icon: Icons.calendar_month_rounded,
                              iconColor: Colors.indigo,
                              title: 'Date & Time',
                              subtitle:
                                  '${widget.event['date']} at ${widget.event['time']}',
                              trailing: TextButton.icon(
                                onPressed: _addToPhoneCalendar,
                                icon: const Icon(
                                  Icons.edit_calendar_rounded,
                                  size: 18,
                                  color: Colors.indigo,
                                ),
                                label: const Text(
                                  'Add',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(height: 24),
                            _buildInfoTile(
                              icon: Icons.location_on_rounded,
                              iconColor: Colors.redAccent,
                              title: 'Location',
                              subtitle:
                                  widget.event['location'] ??
                                  'No Location Specified',
                            ),
                            const Divider(height: 24),
                            _buildInfoTile(
                              icon: Icons.people_alt_rounded,
                              iconColor: Colors.amber.shade700,
                              title: 'Available Seats',
                              subtitle:
                                  '${widget.event['quota'] ?? 'Unlimited'} Attendees Max',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Description Section
                      const Text(
                        'About This Event',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Text(
                          widget.event['description'] ??
                              'No description provided for this event.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar (Fixed at Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ticket Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isFree ? 'Free' : '\$$price',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isJoined
                                ? Colors.green.shade600
                                : Colors.indigo.shade600,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : (_isJoined
                                    ? () => _showTicketModal(context)
                                    : _handleJoinEvent),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(
                                  _isJoined
                                      ? 'Show Digital Ticket 🎟️'
                                      : 'Join Event Now',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

}
