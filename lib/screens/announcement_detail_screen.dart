import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/announcement.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  static const _brand = Color(0xFFFF6319);
  static final _dateFmt = DateFormat('MM/dd/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final a = announcement;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: a.imageUrl != null ? 240 : 0,
            pinned: true,
            backgroundColor: _brand,
            foregroundColor: Colors.white,
            title: Text('Announcements — ${a.terminal}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            flexibleSpace: a.imageUrl != null
                ? FlexibleSpaceBar(
                    background: Image.network(
                      a.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: _brand.withOpacity(0.3),
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.white)),
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildTerminalBadge(a.terminal),
                      const Spacer(),
                      Text(
                        _dateFmt.format(a.publishedAt),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    a.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1919),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    a.body,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalBadge(String terminal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _brand.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        terminal,
        style: const TextStyle(
          color: _brand,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
