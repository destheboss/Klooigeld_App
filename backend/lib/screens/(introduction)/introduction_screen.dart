import 'package:backend/theme/app_theme.dart';
import 'package:backend/components/views/introduction_screen/2_view.dart';
import 'package:backend/components/center_next_button.dart';
import 'package:backend/components/views/introduction_screen/3_vew.dart';
import 'package:backend/components/views/introduction_screen/1_view.dart';
import 'package:backend/components/views/introduction_screen/splash_view.dart';
import 'package:backend/components/top_back_skip_bar.dart';
import 'package:backend/components/views/introduction_screen/4_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:backend/screens/(home)/home_screen.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  IntroductionScreenState createState() => IntroductionScreenState();
}

class IntroductionScreenState extends State<IntroductionScreen>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  final TextEditingController _nameController = TextEditingController();

  String? _avatarImagePath;
  OverlayEntry? _currentOverlayEntry;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8));
    _animationController?.animateTo(0.0);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _removeCurrentOverlay() {
    if (_currentOverlayEntry != null) {
      _currentOverlayEntry!.remove();
      _currentOverlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry(String message) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              _removeCurrentOverlay();
            },
            onVerticalDragEnd: (details) {
              _removeCurrentOverlay();
            },
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.up,
              onDismissed: (_) {
                _removeCurrentOverlay();
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppTheme.klooigeldBlauw,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signUpClick() async {
    String name = _nameController.text;
    if (name.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', name);
      if (_avatarImagePath != null && _avatarImagePath!.isNotEmpty) {
        await prefs.setString('avatarImagePath', _avatarImagePath!);
      } else {
        await prefs.remove('avatarImagePath');
      }
      await prefs.setBool('hasSeenIntroduction', true);
      // Set initial Klooicash as per instructions
      await prefs.setInt('klooicash', 500);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      _removeCurrentOverlay();
      _currentOverlayEntry = _createOverlayEntry("Please enter your name");
      Overlay.of(context).insert(_currentOverlayEntry!);
      Future.delayed(const Duration(seconds: 3), () {
        _removeCurrentOverlay();
      });
    }
  }

  void _onSkipClick() {
    _animationController?.animateTo(0.8,
        duration: const Duration(milliseconds: 1200));
  }

  void _onBackClick() {
    if (_animationController!.value >= 0.8) {
      _animationController?.animateTo(0.6);
    } else if (_animationController!.value >= 0.6) {
      _animationController?.animateTo(0.4);
    } else if (_animationController!.value >= 0.4) {
      _animationController?.animateTo(0.2);
    } else if (_animationController!.value >= 0.2) {
      _animationController?.animateTo(0.0);
    }
  }

  void _onNextClick() {
    if (_animationController!.value <= 0.0) {
      _animationController?.animateTo(0.2);
    } else if (_animationController!.value <= 0.2) {
      _animationController?.animateTo(0.4);
    } else if (_animationController!.value <= 0.4) {
      _animationController?.animateTo(0.6);
    } else if (_animationController!.value <= 0.6) {
      _animationController?.animateTo(0.8);
    } else if (_animationController!.value <= 0.8) {
      _signUpClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.klooigeldGroen,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onPanEnd: (details) {
          final dx = details.velocity.pixelsPerSecond.dx;
          final dy = details.velocity.pixelsPerSecond.dy;

          if (dx.abs() > dy.abs()) {
            if (dx < -300) {
              _onNextClick();
            } else if (dx > 300) {
              _onBackClick();
            }
          } else {
            if (dy < -300) {
              _onNextClick();
            } else if (dy > 300) {
              _onBackClick();
            }
          }
        },
        child: ClipRect(
          child: Stack(
            children: [
              SplashView(
                animationController: _animationController!,
              ),
              FirstView(
                animationController: _animationController!,
              ),
              SecondView(
                animationController: _animationController!,
              ),
              ThirdView(
                animationController: _animationController!,
              ),
              ForthView(
                animationController: _animationController!,
                nameController: _nameController,
                onImageSelected: (imagePath) {
                  setState(() {
                    _avatarImagePath = imagePath;
                  });
                },
              ),
              TopBackSkipView(
                onBackClick: _onBackClick,
                onSkipClick: _onSkipClick,
                animationController: _animationController!,
              ),
              CenterNextButton(
                animationController: _animationController!,
                onNextClick: () {
                  if (_animationController!.value > 0.6 &&
                      _animationController!.value <= 0.8) {
                    _signUpClick();
                  } else {
                    _onNextClick();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
