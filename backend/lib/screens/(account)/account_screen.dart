// Only the parts of the file that changed are shown below, plus necessary context.
// Changes made:
// 1. Moved the gender and lifestyle dropdowns out of the row/column containing the cards,
//    placing them directly below in the main Column. This frees them from the cards'
//    width constraints and allows them to span the full screen width.
// 2. Increased the SAVE button text font size from 14 to 18.

import 'dart:io';
import 'package:backend/features/scenarios/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../theme/app_theme.dart';
import '../../components/widgets/account/avatar_upload_widget.dart';
import '../../components/widgets/home/custom_card.dart';
import '../../services/account_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _showYourDetails = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();

  String? _selectedGender;
  String? _selectedLifestyle;

  bool _showGenderDropdown = false;
  bool _showLifestyleDropdown = false;

  File? _avatarFile;

  final List<Map<String, dynamic>> _genders = [
    {'label': 'Male', 'icon': FontAwesomeIcons.mars},
    {'label': 'Female', 'icon': FontAwesomeIcons.venus},
    {'label': 'Non-binary', 'icon': FontAwesomeIcons.genderless},
    {'label': 'Other', 'icon': FontAwesomeIcons.transgender},
  ];

  final List<Map<String, dynamic>> _lifestyles = [
    {'label': 'Student', 'icon': FontAwesomeIcons.userGraduate},
    {'label': 'Working', 'icon': FontAwesomeIcons.briefcase},
    {'label': 'Part-time job', 'icon': FontAwesomeIcons.clock},
    {'label': 'Freelancer', 'icon': FontAwesomeIcons.laptopCode},
    {'label': 'Other', 'icon': FontAwesomeIcons.question},
  ];

  String? _initialUsername;
  String? _initialAge;
  String? _initialGender;
  String? _initialLifestyle;
  String? _initialAvatarPath;

  bool get _hasChanges {
    return _usernameController.text.trim() != (_initialUsername ?? '') ||
        _ageController.text.trim() != (_initialAge ?? '') ||
        _selectedGender != _initialGender ||
        _selectedLifestyle != _initialLifestyle ||
        (_avatarFile?.path ?? '') != (_initialAvatarPath ?? '');
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await AccountService.loadUserData();
    _initialUsername = data.username ?? '';
    _initialAge = data.age?.toString() ?? '';
    _initialGender = data.gender;
    _initialLifestyle = data.lifestyle;
    _initialAvatarPath = data.avatarPath;

    _usernameController.text = _initialUsername!;
    _ageController.text = _initialAge!;
    _selectedGender = _initialGender;
    _selectedLifestyle = _initialLifestyle;

    if (_initialAvatarPath != null &&
        _initialAvatarPath!.isNotEmpty &&
        File(_initialAvatarPath!).existsSync()) {
      setState(() {
        _avatarFile = File(_initialAvatarPath!);
      });
    }
  }

  Future<void> _saveUserData() async {
    final ageInt = int.tryParse(_ageController.text);
    await AccountService.saveUserData(
      username: _usernameController.text.trim(),
      age: ageInt,
      gender: _selectedGender,
      lifestyle: _selectedLifestyle,
      avatarPath: _avatarFile?.path,
    );

    _initialUsername = _usernameController.text.trim();
    _initialAge = _ageController.text.trim();
    _initialGender = _selectedGender;
    _initialLifestyle = _selectedLifestyle;
    _initialAvatarPath = _avatarFile?.path;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 2),
        content: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.klooigeldGroen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.klooigeldBlauw, width: 2),
            ),
            child: const Text(
              "Changes saved successfully",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.neighbor,
                fontWeight: FontWeight.bold,
                color: AppTheme.klooigeldBlauw,
                fontSize: 14,
              ),
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      ),
    );

    setState(() {});
  }

  Future<void> _pickAvatarImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 600,
    );
    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      maxWidth: 250,
      maxHeight: 250,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppTheme.klooigeldBlauw,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          resetButtonHidden: true,
        ),
      ],
    );
    if (croppedFile != null && mounted) {
      setState(() {
        _avatarFile = File(croppedFile.path);
      });
    }
  }

  void _onPopupMenuSelected(int value) {}

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => CustomDialog(
          icon: FontAwesomeIcons.exclamationTriangle,
          title: "Unsaved Changes",
          content:
              "You have unsaved changes. Are you sure you want to leave without saving?",
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.klooigeldRozeAlt,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontFamily: AppTheme.neighbor,
                        fontSize: 16,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.klooigeldGroen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Leave",
                      style: TextStyle(
                        fontFamily: AppTheme.neighbor,
                        fontSize: 16,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          closeValue: false,
          borderColor: AppTheme.klooigeldBlauw,
          iconColor: AppTheme.klooigeldBlauw,
          closeButtonColor: AppTheme.klooigeldBlauw,
        ),
      );
      if (confirm == null || confirm == false) {
        return false; // Stay on page
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: AppTheme.white,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // HEADER SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            bool canPop = await _onWillPop();
                            if (canPop && mounted) Navigator.pop(context);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(Icons.chevron_left_rounded,
                                size: 30, color: AppTheme.nearlyBlack),
                          ),
                        ),
                        Text(
                          'ACCOUNT',
                          style: TextStyle(
                            fontFamily: AppTheme.titleFont,
                            fontSize: 45,
                            color: AppTheme.nearlyBlack2,
                          ),
                        ),
                        PopupMenuButton<int>(
                          onSelected: _onPopupMenuSelected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.black, width: 2),
                          ),
                          color: AppTheme.white,
                          elevation: 4,
                          itemBuilder: (context) => [
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                children: const [
                                  SizedBox(width: 4),
                                  Text(
                                    'Tips',
                                    style: TextStyle(
                                      fontFamily: AppTheme.neighbor,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 43),
                                  FaIcon(FontAwesomeIcons.lightbulb,
                                      size: 16, color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child:
                                  const Icon(Icons.more_vert, color: AppTheme.nearlyBlack),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // DETAILS / LEADERBOARD SECTION + AVATAR
                  SizedBox(
                    height: 110,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildToggleItem(
                                  icon: FontAwesomeIcons.user,
                                  label: 'Your Details',
                                  isActive: _showYourDetails,
                                  onTap: () {
                                    setState(() {
                                      _showYourDetails = true;
                                    });
                                  },
                                ),
                                _buildToggleItem(
                                  icon: FontAwesomeIcons.trophy,
                                  label: 'Leaderboard',
                                  isActive: !_showYourDetails,
                                  onTap: () {
                                    setState(() {
                                      _showYourDetails = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: -25,
                          child: Center(
                            child: AvatarUploadWidget(
                              avatarFile: _avatarFile,
                              onTap: _pickAvatarImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 0),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showYourDetails
                        ? _buildYourDetailsView(context)
                        : _buildLeaderboardPlaceholder(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYourDetailsView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 40),

          InkWell(
            onTap: () {
              FocusScope.of(context).requestFocus(_usernameFocusNode);
            },
            child: CustomCard(
              backgroundColor: AppTheme.klooigeldGroen,
              shadowColor: Colors.black26,
              onTap: () {
                FocusScope.of(context).requestFocus(_usernameFocusNode);
              },
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'USERNAME',
                          style: TextStyle(
                            fontFamily: AppTheme.titleFont,
                            fontSize: 24,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        TextField(
                          controller: _usernameController,
                          focusNode: _usernameFocusNode,
                          style: const TextStyle(
                            fontFamily: AppTheme.neighbor,
                            fontSize: 16,
                            color: AppTheme.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Your username',
                            hintStyle: TextStyle(
                              fontFamily: AppTheme.neighbor,
                              fontSize: 16,
                              color: AppTheme.white.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: FaIcon(FontAwesomeIcons.user, size: 28, color: AppTheme.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          InkWell(
            onTap: () {
              FocusScope.of(context).requestFocus(_ageFocusNode);
            },
            child: CustomCard(
              backgroundColor: AppTheme.klooigeldRoze,
              shadowColor: Colors.black26,
              onTap: () {
                FocusScope.of(context).requestFocus(_ageFocusNode);
              },
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AGE',
                          style: TextStyle(
                            fontFamily: AppTheme.titleFont,
                            fontSize: 24,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        TextField(
                          controller: _ageController,
                          focusNode: _ageFocusNode,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontFamily: AppTheme.neighbor,
                            fontSize: 16,
                            color: AppTheme.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Your age',
                            hintStyle: TextStyle(
                              fontFamily: AppTheme.neighbor,
                              fontSize: 16,
                              color: AppTheme.white.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: FaIcon(FontAwesomeIcons.calendarDay,
                        size: 28, color: AppTheme.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // GENDER & LIFESTYLE SECTION (no dropdowns inside here anymore)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomCard(
                  backgroundColor: AppTheme.klooigeldPaars,
                  shadowColor: Colors.black26,
                  onTap: () {
                    setState(() {
                      _showLifestyleDropdown = false;
                      _showGenderDropdown = !_showGenderDropdown;
                    });
                  },
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const FaIcon(FontAwesomeIcons.venusMars,
                          size: 48, color: AppTheme.white),
                      const SizedBox(height: 5),
                      Text(
                        'GENDER ${_showGenderDropdown ? '▲' : '▼'}',
                        style: const TextStyle(
                          fontFamily: AppTheme.titleFont,
                          fontSize: 18,
                          color: AppTheme.white,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedGender?.toUpperCase() ?? 'SELECT',
                        style: const TextStyle(
                          fontFamily: AppTheme.neighbor,
                          fontSize: 16,
                          color: AppTheme.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomCard(
                  backgroundColor: AppTheme.klooigeldBlauw,
                  shadowColor: Colors.black26,
                  onTap: () {
                    setState(() {
                      _showGenderDropdown = false;
                      _showLifestyleDropdown = !_showLifestyleDropdown;
                    });
                  },
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const FaIcon(FontAwesomeIcons.briefcase,
                          size: 48, color: AppTheme.white),
                      const SizedBox(height: 5),
                      Text(
                        'LIFESTYLE ${_showLifestyleDropdown ? '▲' : '▼'}',
                        style: const TextStyle(
                          fontFamily: AppTheme.titleFont,
                          fontSize: 18,
                          color: AppTheme.white,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedLifestyle?.toUpperCase() ?? 'SELECT',
                        style: const TextStyle(
                          fontFamily: AppTheme.neighbor,
                          fontSize: 16,
                          color: AppTheme.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Now place the dropdown lists after the row so they are not constrained by the cards
          if (_showGenderDropdown)
            _buildDropdownList(
              context: context,
              options: _genders,
              selectedValue: _selectedGender,
              onSelected: (val) {
                setState(() {
                  _selectedGender = val;
                  _showGenderDropdown = false;
                });
              },
            ),

          if (_showLifestyleDropdown)
            _buildDropdownList(
              context: context,
              options: _lifestyles,
              selectedValue: _selectedLifestyle,
              onSelected: (val) {
                setState(() {
                  _selectedLifestyle = val;
                  _showLifestyleDropdown = false;
                });
              },
            ),

          const SizedBox(height: 16),

          // SAVE BUTTON with increased font size
          if (_hasChanges)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.klooigeldBlauw,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "SAVE",
                  style: TextStyle(
                    fontFamily: AppTheme.neighbor,
                    fontSize: 18, // Increased from 14 to 18
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDropdownList({
    required BuildContext context,
    required List<Map<String, dynamic>> options,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: options.map((option) {
            final isSelected = option['label'] == selectedValue;
            return InkWell(
              onTap: () => onSelected(option['label']),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.klooigeldBlauw.withOpacity(0.1)
                      : AppTheme.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      option['label'],
                      style: const TextStyle(
                        fontFamily: AppTheme.neighbor,
                        fontSize: 14,
                        color: AppTheme.black,
                      ),
                    ),
                    const Spacer(),
                    FaIcon(option['icon'], size: 20, color: AppTheme.nearlyBlack),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.klooigeldBlauw : AppTheme.grey,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [const BoxShadow(color: Colors.black26, offset: Offset(0, 3), blurRadius: 8)]
                  : [],
            ),
            child: Center(
              child: FaIcon(icon, size: 18, color: AppTheme.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: AppTheme.neighbor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
              color: isActive ? AppTheme.nearlyBlack2 : AppTheme.grey,
            ),
          ),
          const SizedBox(height: 4),
          if (isActive)
            Container(
              width: 30,
              height: 2,
              decoration: BoxDecoration(
                color: AppTheme.klooigeldBlauw,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardPlaceholder() {
    return Center(
      key: const ValueKey('leaderboard_view'),
      child: Text(
        "Leaderboard Coming Soon",
        style: TextStyle(
          fontFamily: AppTheme.neighbor,
          fontSize: 16,
          color: AppTheme.black,
        ),
      ),
    );
  }
}
