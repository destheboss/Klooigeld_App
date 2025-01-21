import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- Important import
import '../../../theme/app_theme.dart';

/// Overlay that shows app credits and a GitHub button
class InfoOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const InfoOverlay({
    super.key,
    required this.onClose,
  });

  /// Helper method to launch the GitHub URL
  Future<void> _launchGitHub() async {
    final uri = Uri.parse('https://github.com/destheboss/Klooigeld_App');
    // Attempt to launch in an external application
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Handle error or fallback
      debugPrint('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    /// List of developers, each entry has a 'name', 'image' path, and a 'color'
    final devs = [
      {
        'name': 'Claudiu',
        'image': 'assets/images/claudiu.png',
        'color': AppTheme.klooigeldBlauw,
      },
      {
        'name': 'Debora',
        'image': 'assets/images/debora.jpg',
        'color': AppTheme.klooigeldRozeAlt,
      },
      {
        'name': 'Desislav',
        'image': 'assets/images/desislav.jpg',
        'color': AppTheme.klooigeldBlauw,
      },
      {
        'name': 'Elena',
        'image': 'assets/images/elena.jpg',
        'color': AppTheme.klooigeldRozeAlt,
      },
    ];

    return Positioned.fill(
      child: WillPopScope(
        onWillPop: () async {
          onClose();
          return false;
        },
        child: GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Material(
                elevation: 8,
                color: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER WITH ICON & TEXT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // FontAwesome icon
                                FaIcon(
                                  FontAwesomeIcons.circleInfo,
                                  color: AppTheme.klooigeldBlauw,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Developed by',
                                  style: TextStyle(
                                    fontFamily: AppTheme.titleFont,
                                    fontSize: 24,
                                    color: AppTheme.nearlyBlack2,
                                  ),
                                ),
                              ],
                            ),
                            // CLOSE BUTTON
                            InkWell(
                              onTap: onClose,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppTheme.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.klooigeldBlauw,
                                    width: 1.8,
                                  ),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 19,
                                  color: AppTheme.klooigeldBlauw,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        /// DEVELOPER CARDS
                        for (final dev in devs) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: dev['color'] as Color,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: Image.asset(
                                      dev['image'] as String,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      (dev['name'] as String).toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: AppTheme.neighbor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        /// GITHUB BUTTON (WHITE ICON + WHITE TEXT)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.klooigeldBlauw,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                            icon: const FaIcon(
                              FontAwesomeIcons.github,
                              color: AppTheme.white,
                            ),
                            label: const Text(
                              "GitHub",
                              style: TextStyle(
                                color: AppTheme.white,
                              ),
                            ),
                            onPressed: _launchGitHub,
                          ),
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
    );
  }
}
