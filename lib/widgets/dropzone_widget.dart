import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

/// A drag-and-drop file upload zone for Flutter Web.
///
/// Uses `flutter_dropzone` to create an HTML5 drop target. Files dropped
/// onto this zone are read as [Uint8List] bytes and passed to [onFileDropped].
///
/// Displays a dashed border container with visual feedback on hover,
/// and shows the name of the accepted file formats.
class DropzoneWidget extends StatefulWidget {
  /// Callback invoked when a file is successfully dropped.
  /// Receives the file bytes and filename.
  final void Function(Uint8List bytes, String fileName) onFileDropped;

  /// Callback invoked when an error occurs during file reading.
  final void Function(String error)? onError;

  const DropzoneWidget({
    super.key,
    required this.onFileDropped,
    this.onError,
  });

  @override
  State<DropzoneWidget> createState() => _DropzoneWidgetState();
}

class _DropzoneWidgetState extends State<DropzoneWidget> {
  /// Controller for the underlying DropzoneView.
  late DropzoneViewController _controller;

  /// Whether a file is currently being dragged over the zone.
  bool _isHovering = false;

  /// Accepted MIME types for file filtering.
  static const _acceptedMimeTypes = [
    'text/plain',                                                   // .txt
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document', // .docx
    'application/pdf',                                              // .pdf
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Invisible DropzoneView (must be in the widget tree) ──────
        Positioned.fill(
          child: DropzoneView(
            onCreated: (controller) => _controller = controller,
            onDrop: _handleDrop,
            onHover: () => setState(() => _isHovering = true),
            onLeave: () => setState(() => _isHovering = false),
            onError: (error) => widget.onError?.call(error ?? 'Unknown error'),
            mime: _acceptedMimeTypes,
          ),
        ),

        // ── Visual overlay ───────────────────────────────────────────
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovering
                    ? const Color(0xFF6C63FF)
                    : Colors.white.withValues(alpha: 0.15),
                width: _isHovering ? 2.5 : 1.5,
              ),
              color: _isHovering
                  ? const Color(0xFF6C63FF).withValues(alpha: 0.08)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: _isHovering ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: _isHovering
                        ? const Color(0xFF6C63FF)
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isHovering ? 'Drop your file here' : 'Drag & drop a file here',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _isHovering
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '.txt  •  .docx  •  .pdf',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.3),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Handles a file drop event: reads the file bytes and passes them
  /// to the parent callback along with the filename.
  Future<void> _handleDrop(dynamic event) async {
    setState(() => _isHovering = false);

    try {
      final fileName = await _controller.getFilename(event);
      final bytes = await _controller.getFileData(event);
      widget.onFileDropped(bytes, fileName);
    } catch (e) {
      widget.onError?.call('Failed to read file: $e');
    }
  }
}
