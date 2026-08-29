import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/constants/app_string.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/router/app_router.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/features/auth/entities/auth_state.dart';
import 'package:habitflow/features/auth/providers/auth_provider.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final email = auth.pendingVerificationEmail ?? '';

    ref.listen<AppAuthState>(authStateProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!,
                style: AppTypography.body.copyWith(color: Colors.white)),
            backgroundColor: const Color(0xFFE05A5A),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        ref.read(authStateProvider.notifier).clearError();
      }
      // Verified — pendingVerificationEmail gets cleared by verifyOtp() on
      // success. redirect logic in the router takes it from here.
      if (previous?.pendingVerificationEmail != null &&
          next.pendingVerificationEmail == null &&
          next.error == null) {
        context.go(AppRoutes.bottomNavbar);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(56),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const Gap(24),
              Text(AppString.verifyYourEmail,
                  style: AppTypography.displayMedium),
              const Gap(8),
              Text(
                '${AppString.otpSentMessage} $email',
                style:
                    AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const Gap(40),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: AppTypography.displayMedium.copyWith(letterSpacing: 8),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: AppString.otpHint,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.goalCardBorder),
                  ),
                ),
              ),
              const Gap(28),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: auth.isLoading
                        ? null
                        : () => ref
                            .read(authStateProvider.notifier)
                            .verifyOtp(_otpController.text.trim()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      child: Center(
                        child: auth.isLoading
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
                                AppString.verify,
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(20),
              Center(
                child: TextButton(
                  onPressed: () =>
                      ref.read(authStateProvider.notifier).resendOtp(),
                  child: Text(
                    AppString.resendCode,
                    style: AppTypography.labelLarge
                        .copyWith(color: AppColors.calories),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
