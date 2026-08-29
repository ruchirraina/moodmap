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
import '../providers/sign_up_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (mounted) {
        context.read<SignUpProvider>().onEmailFocusChanged(
          _emailFocusNode.hasFocus,
          _emailController.text,
        );
      }
    });
    _nameFocusNode.addListener(() {
      if (mounted) {
        context.read<SignUpProvider>().onNameFocusChanged(
          _nameFocusNode.hasFocus,
          _nameController.text,
        );
      }
    });
    _passwordFocusNode.addListener(() {
      if (mounted) {
        context.read<SignUpProvider>().onPasswordFocusChanged(
          _passwordFocusNode.hasFocus,
          _passwordController.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _nameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _unfocusNode.dispose();
    _emailController.dispose();
    _nameController.dispose();
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
        _nameController.clear();
        _passwordController.clear();
        context.read<SignUpProvider>().reset();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignUpProvider>();
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
                          AuthConstants.signUpTitleText,
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
                            decoration: InputDecoration(
                              labelText: AuthConstants.emailLabel,
                              errorText: provider.emailError,
                            ),
                            onChanged: (value) {
                              context.read<SignUpProvider>().onEmailChanged(
                                value,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AuthConstants.spacingSmall),
                        ShakeWidget(
                          shouldShake: provider.nameError != null,
                          child: TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            enabled: !isAnyLoading,
                            decoration: InputDecoration(
                              labelText: AuthConstants.nameLabel,
                              errorText: provider.nameError,
                            ),
                            onChanged: (value) {
                              context.read<SignUpProvider>().onNameChanged(
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
                            decoration: InputDecoration(
                              labelText: AuthConstants.passwordCreateLabel,
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
                                              .read<SignUpProvider>()
                                              .togglePasswordVisibility();
                                        },
                                      ),
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              context.read<SignUpProvider>().onPasswordChanged(
                                value,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AuthConstants.spacingLarge),
                        SizedBox(
                          height: AuthConstants.buttonHeight,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onPrimary,
                            ),
                            onPressed: isAnyLoading
                                ? null
                                : () async {
                                    FocusScope.of(context).unfocus();
                                    final success = await context
                                        .read<SignUpProvider>()
                                        .signUp(
                                          _emailController.text,
                                          _nameController.text,
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
                              AuthConstants.existingAccountText,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .tertiary,
                              ),
                              onPressed: isAnyLoading
                                  ? null
                                  : () {
                                      _navigateAndReset(context, () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.push(
                                            AppRoutes.signInPath,
                                            extra: {AppRoutes.argIsPush: true},
                                          );
                                        }
                                      });
                                    },
                              child: const Text(
                                AuthConstants.signInButtonText,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
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
                                          .read<SignUpProvider>()
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
                                        .read<SignUpProvider>();
                                    currentProvider.clearErrors();
                                    final success = await currentProvider
                                        .signUpWithGoogle();
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
