import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/common_widget/common_svg.dart';
import 'package:habitflow/core/constants/app_string.dart';
import 'package:habitflow/core/constants/app_topography.dart';
import 'package:habitflow/core/constants/constant_assets.dart';
import 'package:habitflow/core/constants/size_constant.dart';
import 'package:habitflow/core/router/app_router.dart';
import 'package:habitflow/core/theme/app_theme.dart';
import 'package:habitflow/core/widgets/app_textfield.dart';
import 'package:habitflow/features/auth/entities/auth_state.dart';
import 'package:habitflow/features/auth/providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    ref.listen<AppAuthState>(authStateProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(_errSnack(next.error!));
        ref.read(authStateProvider.notifier).clearError();
      }

      // Fires for both Google and email/password sign-in — either path
      // lands the user in `authenticated` state via the auth stream once
      // Supabase confirms the session. journeySetup is a safe unconditional
      // target: if setup's already done, the router's own redirect gate
      // bounces straight through to the dashboard anyway.
      final justSignedIn =
          previous?.isAuthenticated != true && next.isAuthenticated;
      if (justSignedIn) {
        context.go(AppRoutes.journeySetup);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Soft decorative gradient blobs — gives the screen depth without
          // competing with the content sitting on top of it.
          const Positioned(
            top: -80,
            right: -60,
            child: _GlowBlob(color: AppColors.primary, size: 220),
          ),
          const Positioned(
            // bottom: -100,
            // left: -70,
            child: _GlowBlob(color: AppColors.calories, size: 260),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(56),
                      _BrandMark(),
                      const Gap(56),
                      Text('Welcome back', style: AppTypography.displayLarge),
                      const Gap(8),
                      Text(
                        'Sign in to sync your profile across all devices.',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SBC.xxLH,
                      AppTextField(
                        label: AppString.email,
                        controller: emailController,
                      ),
                      SBC.xLH,
                      AppTextField(
                        label: AppString.email,
                        controller: passwordController,
                      ),
                      SBC.xxLH,
                      _SocialBtn(
                        label: AppString.signIn,
                        emoji: "",
                        isLoading: auth.isLoading,
                        onTap: auth.isLoading
                            ? null
                            : () => ref
                                .read(authStateProvider.notifier)
                                .signInWithEmailPassword(
                                  email: emailController.text,
                                  password: passwordController.text,
                                ),
                      ),
                      SBC.xxLH,
                      _SocialBtn(
                        label: AppString.continueGoogle,
                        emoji: Assets.google,
                        isLoading: auth.isLoading,
                        onTap: auth.isLoading
                            ? null
                            : () => ref
                                .read(authStateProvider.notifier)
                                .signInWithGoogle(),
                      ),
                      const Gap(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_outline_rounded,
                              size: 14, color: AppColors.textMuted),
                          const Gap(6),
                          Text(
                            'Secured sign-in — your data stays private',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                      const Gap(40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppString.dontHaveAccount,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.push(AppRoutes.signUp);
                            },
                            child: Text(
                              'Sign Up',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.calories,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(28),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'By continuing, you agree to our Terms of Service '
                            'and Privacy Policy.',
                            textAlign: TextAlign.center,
                            style: AppTypography.caption,
                          ),
                        ),
                      ),
                      const Gap(32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SnackBar _errSnack(String msg) => SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const Gap(8),
            Expanded(
              child: Text(
                msg,
                style: AppTypography.body.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(
            0xFFE05A5A), // TODO: replace with AppColors.error once defined
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      );
}

/// App icon + name lockup, given more visual weight than a plain row —
/// gradient badge with shadow reads as a considered brand mark rather than
/// a placeholder icon.
class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.calories,
                AppColors.calories.withValues(alpha: 0.75),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.calories.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('🌿', style: TextStyle(fontSize: 28)),
          ),
        ),
        const Gap(14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppString.appName, style: AppTypography.h1),
            const Gap(2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppString.appSubTitle,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Soft blurred color circle used purely as background decoration.
class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label, emoji;
  final bool isLoading;
  final VoidCallback? onTap;
  const _SocialBtn({
    required this.label,
    required this.emoji,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.goalCardBorder, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  )
                else ...[
                  if (emoji.isNotEmpty) ...[
                    CommonSvgWidget(svgName: emoji),
                    const Gap(10),
                  ],
                  Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}
