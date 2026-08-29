// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:habitflow/core/constants/app_string.dart';
// import 'package:habitflow/core/constants/app_topography.dart';
// import 'package:habitflow/core/router/app_router.dart';
// import 'package:habitflow/core/theme/app_theme.dart';
// import 'package:habitflow/core/widgets/app_textfield.dart';
// import 'package:habitflow/features/auth/entities/auth_state.dart';
// import 'package:habitflow/features/auth/providers/auth_provider.dart';

// class SignUpScreen extends ConsumerStatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends ConsumerState<SignUpScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = ref.watch(authStateProvider);

//     ref.listen<AppAuthState>(authStateProvider, (previous, next) {
//       if (next.error != null && next.error != previous?.error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(next.error!,
//                 style: AppTypography.body.copyWith(color: Colors.white)),
//             backgroundColor: const Color(0xFFE05A5A),
//             behavior: SnackBarBehavior.floating,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//         ref.read(authStateProvider.notifier).clearError();
//       }
//       // Account created + OTP sent — move on to verification.
//       if (next.pendingVerificationEmail != null &&
//           next.pendingVerificationEmail != previous?.pendingVerificationEmail) {
//         context.push(AppRoutes.verifyOtp);
//       }
//     });

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 28),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Gap(56),
//               IconButton(
//                 onPressed: () => context.pop(),
//                 icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
//                 padding: EdgeInsets.zero,
//                 alignment: Alignment.centerLeft,
//               ),
//               const Gap(24),
//               Text('Create your account', style: AppTypography.displayLarge),
//               const Gap(8),
//               Text(
//                 'Just an email and password to get started.',
//                 style: AppTypography.body.copyWith(
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               const Gap(40),
//               AppTextField(
//                 label: AppString.email,
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const Gap(20),
//               AppTextField(
//                 label: AppString.password,
//                 controller: _passwordController,
//                 obscureText: true,
//               ),
//               const Gap(32),
//               SizedBox(
//                 width: double.infinity,
//                 child: Material(
//                   color: AppColors.primary,
//                   borderRadius: BorderRadius.circular(18),
//                   child: InkWell(
//                     borderRadius: BorderRadius.circular(18),
//                     onTap: auth.isLoading
//                         ? null
//                         : () => ref.read(authStateProvider.notifier).signUp(
//                               email: _emailController.text.trim(),
//                               password: _passwordController.text,
//                             ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 17),
//                       child: Center(
//                         child: auth.isLoading
//                             ? const SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor:
//                                       AlwaysStoppedAnimation(Colors.white),
//                                 ),
//                               )
//                             : Text(
//                                 AppString.createAccount,
//                                 style: AppTypography.labelLarge.copyWith(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const Gap(24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     AppString.alreadyHaveAccount,
//                     style: AppTypography.body
//                         .copyWith(color: AppColors.textSecondary),
//                   ),
//                   GestureDetector(
//                     onTap: () => context.pop(),
//                     child: Text(
//                       AppString.signIn,
//                       style: AppTypography.labelLarge.copyWith(
//                         color: AppColors.calories,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const Gap(32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
