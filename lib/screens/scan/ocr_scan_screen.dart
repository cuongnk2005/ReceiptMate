import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../services/receipt_parser.dart';
import '../../state/expense_providers.dart';
import '../review/review_screen.dart';

/// Screen for capturing or picking receipt photos with offline OCR processing.
/// Implements the Scanning Radar Beam animation and 100% on-device private pipeline.
class OcrScanScreen extends ConsumerStatefulWidget {
  final ImageSource? initialSource;

  const OcrScanScreen({
    super.key,
    this.initialSource,
  });

  @override
  ConsumerState<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends ConsumerState<OcrScanScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late final AnimationController _scanAnimationController;
  late final Animation<double> _scanAnimation;

  String? _pickedImagePath;
  bool _isProcessing = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.initialSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processImageSource(widget.initialSource!);
      });
    }
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  Future<void> _processImageSource(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 2000,
        imageQuality: 85,
      );

      if (photo == null) {
        if (widget.initialSource != null && mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      setState(() {
        _pickedImagePath = photo.path;
        _isProcessing = true;
        _statusMessage = 'Đang nhận diện ký tự ngoại tuyến với Google ML Kit...';
      });

      _scanAnimationController.repeat(reverse: true);

      final ocrService = ref.read(ocrServiceProvider);
      final recognizedText = await ocrService.processImage(photo.path);

      if (!mounted) return;

      setState(() {
        _statusMessage = 'Đang trích xuất thông tin & chuẩn hóa số tiền...';
      });

      // Quick pause for visual smoothness (< 250ms)
      await Future.delayed(const Duration(milliseconds: 250));

      final parsed = ReceiptParser.parse(recognizedText, imagePath: photo.path);

      if (!mounted) return;

      _scanAnimationController.stop();

      // Navigate to ReviewScreen
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReviewScreen(
            parsedReceipt: parsed,
            initialImagePath: photo.path,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        _scanAnimationController.stop();
        setState(() {
          _isProcessing = false;
          _pickedImagePath = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể quét ảnh hóa đơn: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Radar Scanning Beam View
    if (_isProcessing && _pickedImagePath != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Đang quét hóa đơn', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                _scanAnimationController.stop();
                Navigator.of(context).pop();
              },
              child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Receipt Photo Background
                        Positioned.fill(
                          child: Image.file(
                            File(_pickedImagePath!),
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Soft dark gradient overlay
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.15),
                          ),
                        ),

                        // Animated Scanning Radar Laser Beam
                        AnimatedBuilder(
                          animation: _scanAnimation,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment(0, (_scanAnimation.value * 2) - 1.0),
                              child: Container(
                                height: 4,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFF00E5FF),
                                      Colors.white,
                                      Color(0xFF00E5FF),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                                      blurRadius: 16,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Status and Privacy Notice
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded, color: AppColors.success, size: 14),
                          SizedBox(width: 6),
                          Text(
                            '100% On-Device • Không gửi dữ liệu lên mạng',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default Selection View
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét hóa đơn OCR'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tips Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lightbulb_outline_rounded,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mẹo chụp ảnh rõ nét',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Đặt hóa đơn phẳng, đủ ánh sáng và chụp thẳng góc để nhận diện tổng tiền chính xác nhất.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary Action: Camera
              ElevatedButton.icon(
                onPressed: () => _processImageSource(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded, size: 22),
                label: const Text('Chụp ảnh từ Camera'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),

              const SizedBox(height: 14),

              // Secondary Action: Gallery
              OutlinedButton.icon(
                onPressed: () => _processImageSource(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded, size: 22),
                label: const Text('Chọn ảnh từ Thư viện'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 14),

              // Fallback: Manual Entry
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ReviewScreen()),
                  );
                },
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                label: const Text('Nhập thủ công không cần hóa đơn'),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
