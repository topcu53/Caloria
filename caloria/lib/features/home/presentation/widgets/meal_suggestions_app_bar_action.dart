import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/home_notifications_provider.dart';
import 'home_notifications_sheet.dart';

/// Ana sayfa üst çubuğunda günlük öğün önerilerine giden belirgin giriş.
class MealSuggestionsAppBarAction extends ConsumerWidget {
  const MealSuggestionsAppBarAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = ref.watch(mealSuggestionNotificationUnreadProvider);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Badge(
        isLabelVisible: hasUnread,
        offset: const Offset(-4, 4),
        backgroundColor: AppColors.accent,
        smallSize: 10,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => HomeNotificationsSheet.show(context, ref),
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasUnread
                          ? Icons.auto_awesome_rounded
                          : Icons.restaurant_menu_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Öneriler',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: hasUnread ? 0.2 : 0,
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
