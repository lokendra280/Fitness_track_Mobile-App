import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import '../widgets/edit_field_tile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // TODO: seed these from your real profile provider instead of hardcoded
  // sample values.
  final _firstName = TextEditingController(text: 'Alex');
  final _lastName = TextEditingController(text: 'Hales');
  final _email = TextEditingController(text: 'alexhales@gmail.com');
  final _username = TextEditingController(text: '@alexhales');
  final _dob = TextEditingController(text: 'Apr 23, 1996');
  final _gender = TextEditingController(text: 'Male');
  final _height = TextEditingController(text: '180 cm');
  final _weight = TextEditingController(text: '75 kg');
  final _goal = TextEditingController(text: 'Build Muscle');
  final _level = TextEditingController(text: 'Intermediate');

  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _firstName,
      _lastName,
      _email,
      _username,
      _dob,
      _gender,
      _height,
      _weight,
      _goal,
      _level,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    setState(() => _saving = true);
    // TODO: call your real profile-update provider/repository here.
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _saving = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon:
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                  Expanded(
                    child: Text(
                      'Edit your Profile',
                      textAlign: TextAlign.center,
                      style: AppTypography.h3,
                    ),
                  ),
                  const SizedBox(width: 40), // balances the back button
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Center(child: _EditableAvatar()),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: EditFieldTile(
                            label: 'First Name', controller: _firstName),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: EditFieldTile(
                            label: 'Last Name', controller: _lastName),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  EditFieldTile(
                    label: 'Email',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  EditFieldTile(label: 'User Name', controller: _username),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: EditFieldTile(label: 'DOB', controller: _dob),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:
                            EditFieldTile(label: 'Gender', controller: _gender),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: EditFieldTile(
                          label: 'Height',
                          controller: _height,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: EditFieldTile(
                          label: 'Weight',
                          controller: _weight,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: EditFieldTile(label: 'Goal', controller: _goal),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:
                            EditFieldTile(label: 'Level', controller: _level),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: Material(
                  color: AppColors.journeyGradientTop,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _saving ? null : _handleUpdate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      child: Center(
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                'Update',
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          padding: const EdgeInsets.all(3),
          child: const CircleAvatar(
            backgroundColor: Colors.black12,
            child: Icon(Icons.person_rounded, size: 40, color: Colors.black38),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.camera_alt_rounded,
                size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
