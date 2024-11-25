import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:backend/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ForthView extends StatefulWidget {
  final AnimationController animationController;
  final TextEditingController nameController;
  final Function(String) onImageSelected;

  const ForthView({
    Key? key,
    required this.animationController,
    required this.nameController,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  _ForthViewState createState() => _ForthViewState();
}

class _ForthViewState extends State<ForthView> {
  final FocusNode _focusNode = FocusNode();
  File? _image;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 600,
    );

    if (pickedFile != null) {
      String fileExtension = pickedFile.path.split('.').last.toLowerCase();
      if (fileExtension == 'jpg' ||
          fileExtension == 'jpeg' ||
          fileExtension == 'png') {
        // Now, crop the image
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          maxWidth: 250,
          maxHeight: 250,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: AppTheme.klooigeldBlauw,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Crop Image',
              aspectRatioLockEnabled: true,
              resetButtonHidden: true,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _image = File(croppedFile.path);
          });
          widget.onImageSelected(croppedFile.path);
        }
      } else {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a JPG, JPEG, or PNG image'),
          ),
        );
      }
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
    });
    widget.onImageSelected(''); // Notify parent to clear avatar path
  }

  @override
  Widget build(BuildContext context) {
    // Detect the bottom inset (keyboard height)
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // Define smoother animation parameters
    const keyboardAnimationDuration = Duration(milliseconds: 50);
    const paddingAnimationDuration = keyboardAnimationDuration;
    const paddingAnimationCurve = Curves.ease;

    // Define SlideTransition animations with reduced offsets for smoother motion
    final firstHalfAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: const Interval(
          0.6,
          0.8,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    final secondHalfAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-1, 0),
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: const Interval(
          0.8,
          1.0,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    final welcomeFirstHalfAnimation = Tween<Offset>(
      begin: const Offset(2, 0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: const Interval(
          0.6,
          0.8,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    final welcomeImageAnimation = Tween<Offset>(
      begin: const Offset(4, 0),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: const Interval(
          0.6,
          0.8,
          curve: Curves.fastOutSlowIn,
        ),
      ),
    );

    return GestureDetector(
      onTap: () {
        // Unfocus the text field when tapping outside
        _focusNode.unfocus();
      },
      child: AnimatedPadding(
        padding: EdgeInsets.only(bottom: bottomInset),
        duration: paddingAnimationDuration,
        curve: paddingAnimationCurve,
        child: SlideTransition(
          position: firstHalfAnimation,
          child: SlideTransition(
            position: secondHalfAnimation,
            child: SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 100,
                  bottom: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image Display Widget
                    SlideTransition(
                      position: welcomeImageAnimation,
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 330,
                          maxHeight: 330,
                        ),
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: _image == null
                              ? Image.asset(
                                  'assets/images/introduction_screen/upload_avatar.png',
                                  width: 330,
                                  height: 330,
                                  fit: BoxFit.contain,
                                )
                              : Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Uploaded Image
                                    ClipOval(
                                      child: Image.file(
                                        _image!,
                                        width: 170,
                                        height: 170,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // Avatar Mask Overlay
                                    Image.asset(
                                      'assets/images/introduction_screen/avatar_mask.png',
                                      width: 330,
                                      height: 330,
                                      fit: BoxFit.contain,
                                    ),
                                    // 'X' Icon to Clear Avatar
                                    Positioned(
                                      // Adjust 'top' and 'right' to position the 'X' icon
                                      top: 74,
                                      right: 29,
                                      child: GestureDetector(
                                        onTap: _clearImage,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close_rounded,
                                            size: 50,
                                            color: AppTheme.klooigeldGroen,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 48,
                    ),
                    SlideTransition(
                      position: welcomeFirstHalfAnimation,
                      child: const Text(
                        "WELCOME",
                        style: TextStyle(
                          fontSize: 25.0,
                          fontFamily: 'NeighborBlack',
                          fontWeight: FontWeight.bold,
                          color: AppTheme.klooigeldBlauw,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 16,
                      ),
                      child: Text(
                        "ENTER YOUR NAME TO START YOUR JOURNEY TOWARD BETTER SLEEP",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppTheme.klooigeldBlauw,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 65,
                        vertical: 0,
                      ),
                      child: TextField(
                        controller: widget.nameController,
                        focusNode: _focusNode,
                        style: const TextStyle(
                          color: AppTheme.klooigeldBlauw,
                          fontSize: 12,
                        ),
                        decoration: const InputDecoration(
                          labelText: "HOW SHOULD WE CALL YOU?",
                          labelStyle: TextStyle(
                            color: AppTheme.klooigeldBlauw,
                            fontSize: 12,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.klooigeldBlauw,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppTheme.klooigeldBlauw,
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
        ),
      ),
    );
  }
}
