import 'dart:io';
import 'package:backend/features/scenarios/widgets/custom_dialog.dart';
import 'package:backend/screens/(tips)/tips_screen.dart';
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
  bool _isLoading = true; // Loading state

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

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _genderDropdownKey = GlobalKey();
  final GlobalKey _lifestyleDropdownKey = GlobalKey();

  bool get _hasChanges {
    return _usernameController.text.trim() != (_initialUsername ?? '') ||
        _ageController.text.trim() != (_initialAge ?? '') ||
        _selectedGender != _initialGender ||
        _selectedLifestyle != _initialLifestyle ||
        (_avatarFile?.path ?? '') != (_initialAvatarPath ?? '');
  }

  // Leaderboard-related fields
  int _currentUserKlooicash = 500;
  int _currentUserTapCount = 0;

  final List<Map<String, dynamic>> _allBadges = [
    {'name': 'Buy Now, Pay Later', 'icon': FontAwesomeIcons.shoppingCart},
    {'name': 'Saving', 'icon': FontAwesomeIcons.piggyBank},
    {'name': 'Gambling', 'icon': FontAwesomeIcons.dice},
    {'name': 'Insurances', 'icon': FontAwesomeIcons.shieldHalved},
    {'name': 'Loans', 'icon': FontAwesomeIcons.handHoldingUsd},
    {'name': 'Investing', 'icon': FontAwesomeIcons.chartLine},
  ];

  late List<_LeaderboardUser> _leaderboardUsers;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await AccountService.loadUserData();
    setState(() {
      _initialUsername = data.username ?? '';
      _initialAge = data.age?.toString() ?? '';
      _initialGender = data.gender;
      _initialLifestyle = data.lifestyle;
      _initialAvatarPath = data.avatarPath;

      _usernameController.text = _initialUsername!;
      _ageController.text = _initialAge!;
      _selectedGender = _initialGender;
      _selectedLifestyle = _initialLifestyle;
      _currentUserKlooicash = data.klooicash ?? 500;

      if (_initialAvatarPath != null &&
          _initialAvatarPath!.isNotEmpty &&
          File(_initialAvatarPath!).existsSync()) {
        _avatarFile = File(_initialAvatarPath!);
      } else {
        _avatarFile = null; // Ensure it's null if the file doesn't exist
      }

      _initLeaderboardUsers();

      _isLoading = false; // Data loaded
    });
  }

  void _initLeaderboardUsers() {
    final currentUserName = (_initialUsername != null && _initialUsername!.isNotEmpty)
        ? _initialUsername!
        : "YOU";

    String currentUserAvatar;
    bool isAvatarAsset;

    if (_initialAvatarPath != null &&
        _initialAvatarPath!.isNotEmpty &&
        File(_initialAvatarPath!).existsSync()) {
      currentUserAvatar = _initialAvatarPath!;
      isAvatarAsset = false;
    } else {
      currentUserAvatar = "assets/images/avatar5.png";
      isAvatarAsset = true;
    }

    final fakeUsers = [
      _LeaderboardUser(
        name: "Wiktor",
        avatar: "assets/images/avatar1.png",
        isAvatarAsset: true,
        klooicash: 700,
        badges: _pickRandomBadges(),
        isCurrentUser: false,
      ),
      _LeaderboardUser(
        name: "Andy",
        avatar: "assets/images/avatar2.png",
        isAvatarAsset: true,
        klooicash: 600,
        badges: _pickRandomBadges(),
        isCurrentUser: false,
      ),
      _LeaderboardUser(
        name: "Clau",
        avatar: "assets/images/avatar3.png",
        isAvatarAsset: true,
        klooicash: 550,
        badges: _pickRandomBadges(),
        isCurrentUser: false,
      ),
      _LeaderboardUser(
        name: "Ray",
        avatar: "assets/images/avatar4.png",
        isAvatarAsset: true,
        klooicash: 530,
        badges: _pickRandomBadges(),
        isCurrentUser: false,
      ),
    ];

    final currentUser = _LeaderboardUser(
      name: currentUserName.toUpperCase(),
      avatar: currentUserAvatar,
      isAvatarAsset: isAvatarAsset,
      klooicash: _currentUserKlooicash,
      badges: _pickRandomBadges(),
      isCurrentUser: true,
    );

    _leaderboardUsers = [...fakeUsers, currentUser];
    _sortLeaderboard();
  }

  List<Map<String, dynamic>> _pickRandomBadges() {
    _allBadges.shuffle();
    return _allBadges.take(2).toList();
  }

  void _sortLeaderboard() {
    _leaderboardUsers.sort((a, b) => b.klooicash.compareTo(a.klooicash));
    for (int i = 0; i < _leaderboardUsers.length; i++) {
      _leaderboardUsers[i].rank = i + 1;
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
      klooicash: _currentUserKlooicash,
    );

    setState(() {
      _initialUsername = _usernameController.text.trim();
      _initialAge = _ageController.text.trim();
      _selectedGender = _selectedGender;
      _selectedLifestyle = _selectedLifestyle;
      _initialAvatarPath = _avatarFile?.path;

      _initLeaderboardUsers(); // Re-initialize the leaderboard users
    });

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
              color: AppTheme.klooigeldRoze,
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

    _scrollToTop();
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

  void _onPopupMenuSelected(int value) {
    if (value == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TipsScreen()),
      );
    }
  }

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
        return false;
      }
    }
    return true;
  }

  Future<void> _scrollToDropdown(GlobalKey key) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (key.currentContext != null) {
      await Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  Future<void> _scrollToTop() async {
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleDropdown(
      {required DropdownType dropdownType, required bool currentState}) {
    switch (dropdownType) {
      case DropdownType.gender:
        _showGenderDropdown = !currentState;
        if (_showGenderDropdown) {
          _showLifestyleDropdown = false;
          _scrollToDropdown(_genderDropdownKey);
        } else {
          _scrollToTop();
        }
        break;
      case DropdownType.lifestyle:
        _showLifestyleDropdown = !currentState;
        if (_showLifestyleDropdown) {
          _showGenderDropdown = false;
          _scrollToDropdown(_lifestyleDropdownKey);
        } else {
          _scrollToTop();
        }
        break;
    }
  }

  void _incrementCurrentUserKlooicash() async {
    setState(() {
      final currentUser = _leaderboardUsers.firstWhere((u) => u.isCurrentUser);
      currentUser.klooicash += 40; // add around 40 klooigeld
      _currentUserKlooicash = currentUser.klooicash;
      _sortLeaderboard();
    });
    // Save the updated klooicash
    await AccountService.saveUserData(
      username: _initialUsername ?? '',
      age: int.tryParse(_initialAge ?? ''),
      gender: _initialGender,
      lifestyle: _initialLifestyle,
      avatarPath: _initialAvatarPath,
      klooicash: _currentUserKlooicash,
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
                    FaIcon(option['icon'],
                        size: 20, color: AppTheme.nearlyBlack),
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
                  ? [
                      const BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 3),
                          blurRadius: 8)
                    ]
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

  Widget _buildYourDetailsView(BuildContext context) {
    return Padding(
      key: const ValueKey('details_view'),
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
                    child: FaIcon(FontAwesomeIcons.userLarge,
                        size: 28, color: AppTheme.white),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomCard(
                  backgroundColor: AppTheme.klooigeldPaars,
                  shadowColor: Colors.black26,
                  onTap: () {
                    setState(() {
                      _toggleDropdown(
                        dropdownType: DropdownType.gender,
                        currentState: _showGenderDropdown,
                      );
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
                      _toggleDropdown(
                        dropdownType: DropdownType.lifestyle,
                        currentState: _showLifestyleDropdown,
                      );
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor:
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Column(
              key: const ValueKey('dropdowns'),
              children: [
                if (_showGenderDropdown)
                  Container(
                    key: _genderDropdownKey,
                    child: _buildDropdownList(
                      context: context,
                      options: _genders,
                      selectedValue: _selectedGender,
                      onSelected: (val) {
                        setState(() {
                          _selectedGender = val;
                          _showGenderDropdown = false;
                        });
                        _scrollToTop();
                      },
                    ),
                  ),
                if (_showLifestyleDropdown)
                  Container(
                    key: _lifestyleDropdownKey,
                    child: _buildDropdownList(
                      context: context,
                      options: _lifestyles,
                      selectedValue: _selectedLifestyle,
                      onSelected: (val) {
                        setState(() {
                          _selectedLifestyle = val;
                          _showLifestyleDropdown = false;
                        });
                        _scrollToTop();
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                    fontSize: 18,
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

  Widget _buildLeaderboardView() {
    return Padding(
      key: const ValueKey('leaderboard_view'),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          for (var user in _leaderboardUsers) _buildLeaderboardCard(user),
        ],
      ),
    );
  }

  // Tooltip-related field to manage the overlay entry
  OverlayEntry? _tooltipOverlayEntry;

  /// Displays a custom tooltip above the tapped badge.
  ///
  /// - **Parameters:**
  ///   - `context`: The BuildContext to find the Overlay.
  ///   - `tapPosition`: The global position where the badge was tapped.
  ///   - `badgeName`: The name of the badge to display in the tooltip.
  void _showCustomTooltip(BuildContext context, Offset tapPosition, String badgeName) {
    // Remove any existing tooltip before showing a new one
    _removeTooltip();

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    // Create a new OverlayEntry for the tooltip
    _tooltipOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // Position the tooltip relative to the tap position
        left: tapPosition.dx - 75, // Adjust horizontal position as needed
        top: tapPosition.dy - 60,  // Adjust vertical position as needed
        child: Material(
          color: Colors.transparent, // Ensure the material is transparent
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.klooigeldBlauw.withOpacity(0.8), // Tooltip background color
              borderRadius: BorderRadius.circular(8),             // Rounded corners
              border: Border.all(color: AppTheme.klooigeldBlauw.withOpacity(0.8), width: 2), // Border styling
            ),
            child: Text(
              badgeName,
              style: const TextStyle(
                fontFamily: AppTheme.neighbor,
                fontSize: 14,
                color: AppTheme.white, // Tooltip text color
              ),
            ),
          ), 
        ),
      ),
    );

    // Insert the tooltip into the overlay
    overlay.insert(_tooltipOverlayEntry!);

    // Automatically remove the tooltip after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _removeTooltip();
    });
  }

  /// Removes the currently displayed tooltip, if any.
  void _removeTooltip() {
    _tooltipOverlayEntry?.remove(); // Remove the overlay entry from the overlay
    _tooltipOverlayEntry = null;    // Reset the reference
  }

  Widget _buildLeaderboardCard(_LeaderboardUser user) {
    Color cardColor;
    switch (user.rank) {
      case 1:
        cardColor = AppTheme.klooigeldRoze;
        break;
      case 2:
        cardColor = AppTheme.klooigeldPaars;
        break;
      case 3:
        cardColor = AppTheme.klooigeldBlauw;
        break;
      default:
        cardColor = AppTheme.klooigeldGroen;
        break;
    }

    return AnimatedSwitcher(
      key: ValueKey(user.name + user.rank.toString()),
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
              .animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: GestureDetector(
        key: ValueKey(user.name),
        onTap: () {
          if (user.isCurrentUser) {
            _currentUserTapCount++;
            if (_currentUserTapCount >= 5) {
              _currentUserTapCount = 0;
              _incrementCurrentUserKlooicash();
            }
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                "${user.rank}",
                style: const TextStyle(
                  fontFamily: AppTheme.titleFont,
                  fontSize: 24,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(width: 12),
              ClipOval(
                child: user.isAvatarAsset
                    ? Image.asset(
                        user.avatar,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : (File(user.avatar).existsSync()
                        ? Image.file(
                            File(user.avatar),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "assets/images/avatar5.png",
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  user.name.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: AppTheme.neighbor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: user.badges.map((badge) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTapDown: (details) {
                        // Show the custom tooltip when the badge is tapped
                        _showCustomTooltip(
                          context,
                          details.globalPosition,
                          badge['name'],
                        );
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: FaIcon(
                            badge['icon'],
                            size: 16,
                            color: cardColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }).take(2).toList(),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Text(
                    '${user.klooicash}',
                    style: const TextStyle(
                      fontFamily: AppTheme.neighbor,
                      fontSize: 18,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Transform.translate(
                    offset: const Offset(0, 0.6),
                    child: Image.asset(
                      'assets/images/currency_white.png',
                      width: 14,
                      height: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 26, vertical: 16),
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
                                  border: Border.all(
                                      color: Colors.black, width: 2),
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
                                side: const BorderSide(
                                    color: Colors.black, width: 2),
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
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                  ),
                                  child: const Icon(Icons.more_vert,
                                      color: AppTheme.nearlyBlack),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 110,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 28),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildToggleItem(
                                      icon: FontAwesomeIcons.user,
                                      label: 'Your Details',
                                      isActive: _showYourDetails,
                                      onTap: () {
                                        setState(() {
                                          _showYourDetails = true;
                                          _showGenderDropdown = false;
                                          _showLifestyleDropdown = false;
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
                                          _showGenderDropdown = false;
                                          _showLifestyleDropdown = false;
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
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        firstChild: _buildYourDetailsView(context),
                        secondChild: _buildLeaderboardView(),
                        crossFadeState: _showYourDetails
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstCurve: Curves.easeInOut,
                        secondCurve: Curves.easeInOut,
                        sizeCurve: Curves.easeInOut,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    ),
  );
}
}

enum DropdownType { gender, lifestyle }

class _LeaderboardUser {
  final String name;
  final String avatar;
  final bool isAvatarAsset; // New flag to indicate avatar type
  int klooicash;
  final bool isCurrentUser;
  final List<Map<String, dynamic>> badges;
  int rank;

  _LeaderboardUser({
    required this.name,
    required this.avatar,
    required this.isAvatarAsset, // Initialize the flag
    required this.klooicash,
    required this.badges,
    required this.isCurrentUser,
    this.rank = 0,
  });
}
