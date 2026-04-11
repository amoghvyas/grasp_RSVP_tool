import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/message_service.dart';
import 'apple_widgets.dart';

class DeveloperOverlay extends StatefulWidget {
  const DeveloperOverlay({super.key});

  @override
  State<DeveloperOverlay> createState() => _DeveloperOverlayState();
}

class _DeveloperOverlayState extends State<DeveloperOverlay> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  String? _status;

  Future<void> _handleSend() async {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _isSending = true;
      _status = null;
    });
    try {
      await MessageService.sendMessage(_messageController.text);
      setState(() => _status = 'Message sent! 🚀');
      _messageController.clear();
    } catch (e) {
      setState(() => _status = 'Error sending message. Please check EmailJS.');
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Deep Glass Blur
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.1),
              ),
            ),
          ),
          
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Profile Section
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? Colors.black : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/developer.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.person_rounded, 
                                    size: 60, 
                                    color: isDark ? Colors.white24 : Colors.black12
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Amogh Vyas',
                              style: GoogleFonts.outfit(
                                fontSize: 28, 
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'B.Tech IT • Academic Excellence',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54, 
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Suggest a Feature
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'SUGGEST A FEATURE',
                                style: GoogleFonts.outfit(
                                  fontSize: 11, 
                                  fontWeight: FontWeight.w800, 
                                  letterSpacing: 1.2,
                                  color: isDark ? Colors.white24 : Colors.black26,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _messageController,
                              maxLines: 4,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Drop a hi or suggest a feature...',
                                hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                                filled: true,
                                fillColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16), 
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            if (_status != null) ...[
                              const SizedBox(height: 12),
                              Text(_status!, style: const TextStyle(fontSize: 13, color: Color(0xFF34C759), fontWeight: FontWeight.w600)),
                            ],
                            const SizedBox(height: 24),
                            AppleButton(
                              label: 'Send Message',
                              isLoading: _isSending,
                              onPressed: _handleSend,
                              width: double.infinity,
                            ),
                            
                            const SizedBox(height: 32),
                            Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                            const SizedBox(height: 32),

                            // Social Links as Logos
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _logoBtn(
                                  'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png', 
                                  'https://github.com/amoghvyas',
                                  isDark,
                                ),
                                const SizedBox(width: 32),
                                _logoBtn(
                                  'https://cdn-icons-png.flaticon.com/512/174/174857.png', 
                                  'https://linkedin.com/in/amoghvyas',
                                  isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoBtn(String logoUrl, String url, bool isDark) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)),
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            isDark ? Colors.white : Colors.black,
            BlendMode.srcIn,
          ),
          child: Image.network(logoUrl, width: 24, height: 24),
        ),
      ),
    );
  }
}
