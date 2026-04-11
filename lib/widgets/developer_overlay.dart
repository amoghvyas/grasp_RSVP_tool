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
      // Auto-dismiss after success? No, let user read success message.
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
          // Background Blur
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.6)),
            ),
          ),
          
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AppleCard(
                  padding: const EdgeInsets.all(32),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Profile Section
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.black10, width: 2),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/developer.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.person_rounded, 
                                size: 50, 
                                color: isDark ? Colors.white24 : Colors.black12
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Amogh Vyas',
                          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'B.Tech IT • Academic Excellence',
                          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                        ),
                        
                        const SizedBox(height: 32),
                        const Divider(height: 1),
                        const SizedBox(height: 32),

                        // Suggest a Feature (Now right below the profile)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'SUGGEST A FEATURE',
                            style: GoogleFonts.outfit(
                              fontSize: 10, 
                              fontWeight: FontWeight.w800, 
                              letterSpacing: 1.5,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _messageController,
                          maxLines: 4,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Drop a hi or suggest a new feature...',
                            filled: true,
                            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        if (_status != null) ...[
                          const SizedBox(height: 12),
                          Text(_status!, style: TextStyle(fontSize: 12, color: _status!.contains('sent') ? Colors.green : Colors.red)),
                        ],
                        const SizedBox(height: 20),
                        AppleButton(
                          label: 'Send Message',
                          isLoading: _isSending,
                          onPressed: _handleSend,
                          width: double.infinity,
                        ),
                        
                        const SizedBox(height: 32),
                        const Divider(height: 1),
                        const SizedBox(height: 24),

                        // Social Links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialBtn('GitHub', 'https://github.com/amoghvyas', isDark),
                            const SizedBox(width: 12),
                            _socialBtn('LinkedIn', 'https://linkedin.com/in/amoghvyas', isDark),
                          ],
                        ),
                      ],
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

  Widget _socialBtn(String label, String url, bool isDark) {
    return AppleButton(
      label: label,
      isPrimary: false,
      onPressed: () => launchUrl(Uri.parse(url)),
    );
  }
}
