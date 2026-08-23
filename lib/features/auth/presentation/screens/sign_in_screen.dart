import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_animations.dart';
import '../../../../core/widgets/shake_widget.dart';
import '../../constants/auth_constants.dart';
import '../providers/sign_in_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (mounted) {
        context.read<SignInProvider>().onEmailFocusChanged(
          _emailFocusNode.hasFocus,
          _emailController.text,
        );
      }
    });
    _passwordFocusNode.addListener(() {
      if (mounted) {
        context.read<SignInProvider>().onPasswordFocusChanged(
          _passwordFocusNode.hasFocus,
          _passwordController.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _unfocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateAndReset(BuildContext context, VoidCallback navigateAction) {
    _unfocusNode.requestFocus();
    navigateAction();
    Future.delayed(
      const Duration(milliseconds: AuthConstants.navigateResetDelayMs),
      () {
        if (!context.mounted) return;
        _emailController.clear();
        _passwordController.clear();
        context.read<SignInProvider>().reset();
      },
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String label,
    Widget? suffixIcon,
    String? errorText,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthConstants.borderRadius),
      borderSide: BorderSide.none,
    );
    final activeBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthConstants.borderRadius),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: AuthConstants.borderWidth,
      ),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthConstants.borderRadius),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: AuthConstants.borderWidth,
      ),
    );

    return InputDecoration(
      labelText: label,
      errorText: errorText,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AuthConstants.horizontalPadding,
        vertical: AuthConstants.inputVerticalPadding,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: activeBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignInProvider>();
    final isAnyLoading = provider.isEmailLoading || provider.isGoogleLoading;

    return Scaffold(
      body: Focus(
        focusNode: _unfocusNode,
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              _unfocusNode.requestFocus();
            },
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AuthConstants.horizontalPadding,
                      vertical: AuthConstants.verticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AuthConstants.signInTitleText,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AuthConstants.spacingLarge),
                        ShakeWidget(
                          shouldShake: provider.emailError != null,
                          child: TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isAnyLoading,
                            decoration: _buildInputDecoration(
                              context,
                              label: AuthConstants.emailLabel,
                              errorText: provider.emailError,
                            ),
                            onChanged: (value) {
                              context.read<SignInProvider>().onEmailChanged(
                                value,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AuthConstants.spacingSmall),
                        ShakeWidget(
                          shouldShake: provider.passwordError != null,
                          child: TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: !provider.isPasswordVisible,
                            enabled: !isAnyLoading,
                            decoration: _buildInputDecoration(
                              context,
                              label: AuthConstants.passwordEnterLabel,
                              errorText: provider.passwordError,
                              suffixIcon: provider.isPasswordFocused
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        right: AuthConstants.suffixIconPadding,
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          provider.isPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<SignInProvider>()
                                              .togglePasswordVisibility();
                                        },
                                      ),
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              context.read<SignInProvider>().onPasswordChanged(
                                value,
                              );
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary,
                            ),
                            onPressed: isAnyLoading
                                ? null
                                : () {
                                    _unfocusNode.requestFocus();
                                    AppRouter.isNavigatingToForgotPassword =
                                        true;
                                    context
                                        .push(AppRoutes.forgotPasswordPath)
                                        .whenComplete(() {
                                          Future.delayed(
                                            AppAnimations.slideDuration,
                                            () {
                                              if (mounted) {
                                                AppRouter
                                                        .isNavigatingToForgotPassword =
                                                    false;
                                              }
                                            },
                                          );
                                        });
                                  },
                            child: const Text(AuthConstants.forgotPasswordText),
                          ),
                        ),
                        const SizedBox(height: AuthConstants.spacingLarge),
                        SizedBox(
                          height: AuthConstants.buttonHeight,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondary,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSecondary,
                            ),
                            onPressed: isAnyLoading
                                ? null
                                : () async {
                                    FocusScope.of(context).unfocus();
                                    final success = await context
                                        .read<SignInProvider>()
                                        .signIn(
                                          _emailController.text,
                                          _passwordController.text,
                                        );
                                    if (!context.mounted) return;
                                    if (success) {
                                      AppRouter.navigateSequentially(
                                        context,
                                        AppRoutes.homePath,
                                      );
                                    }
                                  },
                            child: provider.isEmailLoading
                                ? SpinKitThreeBounce(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(
                                          alpha:
                                              AuthConstants.disabledTextAlpha,
                                        ),
                                    size: AuthConstants.iconSizeSmall,
                                  )
                                : const Text(
                                    AuthConstants.continueButtonText,
                                    style: TextStyle(
                                      fontSize: AuthConstants.buttonTextSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: AuthConstants.spacingMedium),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AuthConstants.newAccountText,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary,
                              ),
                              onPressed: isAnyLoading
                                  ? null
                                  : () {
                                      _navigateAndReset(context, () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.push(
                                            AppRoutes.signUpPath,
                                            extra: {AppRoutes.argIsPush: true},
                                          );
                                        }
                                      });
                                    },
                              child: const Text(AuthConstants.signUpButtonText),
                            ),
                          ],
                        ),
                        const SizedBox(height: AuthConstants.spacingMedium),
                        AnimatedSize(
                          duration: AppAnimations.animatedSizeDuration,
                          curve: Curves.easeInOut,
                          child: provider.genericError != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AuthConstants.spacingMedium,
                                  ),
                                  child: Dismissible(
                                    key: Key(provider.genericError!),
                                    onDismissed: (_) {
                                      context
                                          .read<SignInProvider>()
                                          .clearGenericError();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AuthConstants.spacingMedium,
                                        vertical: AuthConstants.spacingSmall,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .errorContainer,
                                        borderRadius: BorderRadius.circular(
                                          AuthConstants.borderRadius,
                                        ),
                                      ),
                                      child: Text(
                                        provider.genericError!,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onErrorContainer,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AuthConstants.spacingSmall,
                              ),
                              child: Text(
                                AuthConstants.orText,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: AuthConstants.spacingMedium),
                        SizedBox(
                          height: AuthConstants.buttonHeight,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            onPressed: isAnyLoading
                                ? null
                                : () async {
                                    FocusScope.of(context).unfocus();
                                    final currentProvider = context
                                        .read<SignInProvider>();
                                    currentProvider.clearErrors();
                                    final success = await currentProvider
                                        .signInWithGoogle();
                                    if (!context.mounted) return;
                                    if (success) {
                                      AppRouter.navigateSequentially(
                                        context,
                                        AppRoutes.homePath,
                                      );
                                    }
                                  },
                            child: provider.isGoogleLoading
                                ? SpinKitThreeBounce(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(
                                          alpha:
                                              AuthConstants.disabledTextAlpha,
                                        ),
                                    size: AuthConstants.iconSizeSmall,
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Opacity(
                                        opacity: isAnyLoading
                                            ? AuthConstants.disabledLogoOpacity
                                            : AuthConstants.enabledLogoOpacity,
                                        child: Image.asset(
                                          AppAssets.googleLogo,
                                          height: AuthConstants.iconSizeSmall,
                                          width: AuthConstants.iconSizeSmall,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: AuthConstants.spacingSmall,
                                      ),
                                      const Text(
                                        AuthConstants.googleButtonText,
                                        style: TextStyle(
                                          fontSize:
                                              AuthConstants.buttonTextSize,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
