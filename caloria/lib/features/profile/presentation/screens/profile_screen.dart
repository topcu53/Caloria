import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/nutrition_goal_calculator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String _gender = 'male';
  String _activityLevel = 'moderate';
  String _goal = 'maintain';
  NutritionGoals? _previewGoals;
  bool _isSaving = false;
  bool _isSavingName = false;

  bool _loadedFromProfile = false;
  bool _loadedDisplayName = false;

  void _loadFromProfile(UserProfileEntity? profile, UserEntity? authUser) {
    if (profile == null && authUser == null) return;
    if (!_loadedDisplayName) {
      _loadedDisplayName = true;
      final name = profile?.displayName?.trim().isNotEmpty == true
          ? profile!.displayName!.trim()
          : authUser?.displayName?.trim();
      if (name != null && name.isNotEmpty) {
        _displayNameController.text = name;
      } else if (authUser?.isAnonymous == true) {
        _displayNameController.text = 'Misafir';
      }
    }
    if (profile == null) return;
    if (profile.weight != null) {
      _weightController.text = profile.weight!.toStringAsFixed(1);
    }
    if (profile.height != null) {
      _heightController.text = profile.height!.toStringAsFixed(0);
    }
    if (profile.age != null) {
      _ageController.text = profile.age.toString();
    }
    if (profile.gender == 'male' || profile.gender == 'female') {
      _gender = profile.gender!;
    }
    const activityLevels = [
      'sedentary',
      'light',
      'moderate',
      'active',
      'very_active',
    ];
    if (activityLevels.contains(profile.activityLevel)) {
      _activityLevel = profile.activityLevel!;
    }
    const goals = ['lose', 'maintain', 'gain'];
    if (goals.contains(profile.goal)) {
      _goal = profile.goal!;
    }
    if (profile.targetWeightKg != null) {
      _targetWeightController.text =
          profile.targetWeightKg!.toStringAsFixed(1);
    }
    _updatePreview();
    setState(() {});
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final height = double.tryParse(_heightController.text.replaceAll(',', '.'));
    final age = int.tryParse(_ageController.text);

    if (weight == null || height == null || age == null || weight <= 0 || height <= 0) {
      setState(() => _previewGoals = null);
      return;
    }

    try {
      setState(() {
        _previewGoals = NutritionGoalCalculator.calculate(
          weightKg: weight,
          heightCm: height,
          age: age,
          gender: _gender,
          activityLevel: _activityLevel,
          goal: _goal,
        );
      });
    } catch (_) {
      setState(() => _previewGoals = null);
    }
  }

  static String _userInitial({
    required UserEntity user,
    UserProfileEntity? profile,
  }) {
    final name = profile?.displayName?.trim().isNotEmpty == true
        ? profile!.displayName!.trim()
        : user.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name.characters.first.toUpperCase();
    }
    final email = user.email.trim();
    if (email.isNotEmpty) {
      return email.characters.first.toUpperCase();
    }
    return '?';
  }

  static String _resolvedDisplayName({
    required UserEntity user,
    UserProfileEntity? profile,
  }) {
    final fromProfile = profile?.displayName?.trim();
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
    final fromAuth = user.displayName?.trim();
    if (fromAuth != null && fromAuth.isNotEmpty) return fromAuth;
    if (user.isAnonymous) return 'Misafir';
    return 'Kullanıcı';
  }

  Future<void> _saveDisplayName() async {
    final name = _displayNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir isim girin')),
      );
      return;
    }

    setState(() => _isSavingName = true);
    try {
      await ref.read(profileNotifierProvider.notifier).saveDisplayName(name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İsim kaydedildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İsim kaydedilemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingName = false);
    }
  }

  Future<void> _signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _previewGoals == null) return;

    setState(() => _isSaving = true);
    try {
      final targetWeight = double.tryParse(
        _targetWeightController.text.replaceAll(',', '.'),
      );
      await ref.read(profileNotifierProvider.notifier).saveBodyMetricsAndGoals(
            weightKg: double.parse(_weightController.text.replaceAll(',', '.')),
            heightCm: double.parse(_heightController.text.replaceAll(',', '.')),
            age: int.parse(_ageController.text),
            gender: _gender,
            activityLevel: _activityLevel,
            goal: _goal,
            targetWeightKg:
                targetWeight != null && targetWeight > 0 ? targetWeight : null,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hedefler kaydedildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt başarısız: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final authUser = ref.watch(authStateProvider).valueOrNull;

    profileAsync.whenData((profile) {
      if (!_loadedFromProfile || !_loadedDisplayName) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (profile != null) _loadedFromProfile = true;
          _loadFromProfile(profile, authUser);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Hedefler')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (authUser != null) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    _userInitial(
                      user: authUser,
                      profile: profileAsync.valueOrNull,
                    ),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _resolvedDisplayName(
                          user: authUser,
                          profile: profileAsync.valueOrNull,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authUser.email.trim().isNotEmpty
                            ? authUser.email
                            : 'Misafir hesap',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Görünen ad',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (authUser.isAnonymous)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  'Misafir olarak giriş yaptınız; istediğiniz ismi yazıp kaydedebilirsiniz.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              )
            else
              const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _displayNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Adınız',
                      hintText: 'Örn. Burak',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _isSavingName ? null : _saveDisplayName,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(88, 52),
                  ),
                  child: _isSavingName
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kaydet'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Çıkış yap'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ),
            const Divider(height: 32),
          ],
          const SizedBox(height: 4),
          Text(
            'Vücut bilgileri',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Boy ve kilonuza göre günlük kalori ile protein, karbonhidrat ve yağ hedefleri hesaplanır.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Kilo (kg)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _updatePreview(),
                        validator: (v) {
                          final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                          if (n == null || n <= 0) return 'Geçerli kilo girin';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Boy (cm)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _updatePreview(),
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n < 100 || n > 250) {
                            return '100-250 cm arası';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Yaş',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _updatePreview(),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 10 || n > 120) return 'Geçerli yaş girin';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _SectionTitle('Cinsiyet'),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'male', label: Text('Erkek')),
                    ButtonSegment(value: 'female', label: Text('Kadın')),
                  ],
                  selected: {_gender},
                  onSelectionChanged: (s) {
                    if (s.isEmpty) return;
                    setState(() => _gender = s.first);
                    _updatePreview();
                  },
                ),
                const SizedBox(height: 20),
                _SectionTitle('Aktivite seviyesi'),
                DropdownButtonFormField<String>(
                  value: _activityLevel,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'sedentary', child: Text('Hareketsiz')),
                    DropdownMenuItem(value: 'light', child: Text('Hafif aktif')),
                    DropdownMenuItem(value: 'moderate', child: Text('Orta aktif')),
                    DropdownMenuItem(value: 'active', child: Text('Aktif')),
                    DropdownMenuItem(value: 'very_active', child: Text('Çok aktif')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _activityLevel = v);
                      _updatePreview();
                    }
                  },
                ),
                const SizedBox(height: 20),
                _SectionTitle('Hedef'),
                DropdownButtonFormField<String>(
                  value: _goal,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'lose', child: Text('Kilo ver')),
                    DropdownMenuItem(value: 'maintain', child: Text('Korumak')),
                    DropdownMenuItem(value: 'gain', child: Text('Kilo al')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _goal = v);
                      _updatePreview();
                    }
                  },
                ),
                const SizedBox(height: 20),
                _SectionTitle('Hedeflenen kilo'),
                TextFormField(
                  controller: _targetWeightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Hedef kilo (kg)',
                    hintText: 'Örn. 72',
                    border: OutlineInputBorder(),
                    suffixText: 'kg',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = double.tryParse(v.replaceAll(',', '.'));
                    if (n == null || n <= 0) return 'Geçerli hedef kilo girin';
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'İlerleme sekmesinde kilo takibinde bu hedef kullanılır.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_previewGoals != null) _GoalsPreviewCard(goals: _previewGoals!),
          if (profileAsync.valueOrNull?.hasBodyMetrics == true &&
              _previewGoals == null)
            _CurrentGoalsCard(profile: profileAsync.value!),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSaving || _previewGoals == null ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Hedefleri kaydet'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _GoalsPreviewCard extends StatelessWidget {
  final NutritionGoals goals;
  const _GoalsPreviewCard({required this.goals});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hesaplanan günlük hedefler',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'VKİ: ${goals.bmi} (${goals.bmiCategory})',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const Divider(height: 24),
          _GoalLine('Kalori', '${goals.dailyCalories.toInt()} kcal'),
          _GoalLine('Protein', '${goals.dailyProtein.toInt()} g'),
          _GoalLine('Karbonhidrat', '${goals.dailyCarbs.toInt()} g'),
          _GoalLine('Yağ', '${goals.dailyFat.toInt()} g'),
        ],
      ),
    );
  }
}

class _CurrentGoalsCard extends StatelessWidget {
  final UserProfileEntity profile;
  const _CurrentGoalsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kayıtlı hedefleriniz',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _GoalLine('Kalori', '${profile.dailyCalorieGoal.toInt()} kcal'),
          _GoalLine('Protein', '${profile.dailyProteinGoal.toInt()} g'),
          _GoalLine('Karbonhidrat', '${profile.dailyCarbsGoal.toInt()} g'),
          _GoalLine('Yağ', '${profile.dailyFatGoal.toInt()} g'),
        ],
      ),
    );
  }
}

class _GoalLine extends StatelessWidget {
  final String label;
  final String value;
  const _GoalLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
