import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/reader_provider.dart';
import 'apple_widgets.dart';

class GratitudeAnnouncement extends StatelessWidget {
  const GratitudeAnnouncement({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReaderProvider>();
    final state = provider.state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const announcementId = 'launch_gratitude_v1';
    final lastShown = state.shownAnnouncements[announcementId];
    
    // Logic: Active for 15 days since current build date (Approx April 13, 2026)
    final now = DateTime.now();
    final expiry = DateTime(2026, 4, 28); // 15 days from now
    
    if (now.isAfter(expiry)) return const SizedBox.shrink();
    if (lastShown != null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: AppleCard(
        color: const Color(0xFF0071E3).withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            const Icon(Icons.celebration_rounded, color: Color(0xFF0071E3), size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overwhelming Hospitality',
                    style: GoogleFonts.outfit(
                      fontSize: 16, 
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'The response to Grasp has been incredible. Thank you for scholarly engagement and feedback!',
                    style: TextStyle(
                      fontSize: 13, 
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () => provider.dismissAnnouncement(announcementId),
              icon: const Icon(Icons.close_rounded, size: 20),
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
