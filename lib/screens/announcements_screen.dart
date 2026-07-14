import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/announcement.dart';
import '../services/announcement_service.dart';
import 'announcement_detail_screen.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  static const _brand = Color(0xFFFF6319);
  final _service = AnnouncementService();

  List<Announcement> _announcements = [];
  bool _loading = true;
  String? _error;
  String _terminal = 'All';

  static const _terminals = ['All', 'MICT', 'AGCT', 'MICTSI'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _service.getAnnouncements(
          terminal: _terminal == 'All' ? null : _terminal);
      setState(() { _announcements = result; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        title: const Text('Announcements',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          _buildTerminalTabs(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildTerminalTabs() {
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _terminals.length,
        itemBuilder: (_, i) {
          final t = _terminals[i];
          final selected = t == _terminal;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _terminal = t);
                _load();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? _brand : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _brand));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text('Failed to load announcements'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_announcements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No announcements', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: _brand,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _announcements.length,
        itemBuilder: (_, i) => _AnnouncementCard(
          announcement: _announcements[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnnouncementDetailScreen(
                  announcement: _announcements[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const _AnnouncementCard(
      {required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = announcement;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.imageUrl != null) _buildHeroImage(a.imageUrl!),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildTerminalBadge(a.terminal),
                      if (a.categoryIcon != null) ...[
                        const SizedBox(width: 6),
                        Icon(_iconForCategory(a.categoryIcon!),
                            size: 14, color: Colors.grey),
                      ],
                      const Spacer(),
                      Text(
                        timeago.format(a.publishedAt),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    a.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1919),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.excerpt,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(String url) {
    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(10)),
      child: Image.network(
        url,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 160,
          color: Colors.grey.shade200,
          child:
              const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildTerminalBadge(String terminal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6319).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        terminal,
        style: const TextStyle(
          color: Color(0xFFFF6319),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'truck': return Icons.local_shipping;
      case 'vessel': return Icons.directions_boat;
      case 'alert': return Icons.warning_amber;
      default: return Icons.info_outline;
    }
  }
}
