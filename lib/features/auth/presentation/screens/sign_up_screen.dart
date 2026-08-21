import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
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

  void _navigateAndReset(VoidCallback navigateAction) {
    _unfocusNode.requestFocus();
    navigateAction();
    Future.delayed(
      const Duration(milliseconds: AuthConstants.navigateResetDelayMs),
      () {
        if (mounted) {
          _emailController.clear();
          _nameController.clear();
          _passwordController.clear();
          context.read<SignUpProvider>().reset();
        }
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
    final provider = context.watch<SignUpProvider>();

    return Scaffold(
      body: Focus(
        focusNode: _unfocusNode,
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              _unfocusNode.requestFocus();
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AuthConstants.horizontalPadding,
                    vertical: AuthConstants.verticalPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight -
                          (AuthConstants.verticalPadding * 2),
                    ),
                    child: IntrinsicHeight(
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
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _buildInputDecoration(
                              context,
                              label: AuthConstants.emailLabel,
                              errorText: provider.emailError,
                            ),
                            onChanged: (value) {
                              context.read<SignUpProvider>().onEmailChanged(
                                value,
                              );
                            },
                          ),
                          const SizedBox(height: AuthConstants.spacingSmall),
                          TextFormField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            decoration: _buildInputDecoration(
                              context,
                              label: AuthConstants.nameLabel,
                              errorText: provider.nameError,
                            ),
                            onChanged: (value) {
                              context.read<SignUpProvider>().onNameChanged(
                                value,
                              );
                            },
                          ),
                          const SizedBox(height: AuthConstants.spacingSmall),
                          TextFormField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: !provider.isPasswordVisible,
                            decoration: _buildInputDecoration(
                              context,
                              label: AuthConstants.passwordCreateLabel,
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
                          const SizedBox(height: AuthConstants.spacingLarge),
                          SizedBox(
                            height: AuthConstants.buttonHeight,
                            child: FilledButton(
                              onPressed: () {
                                _unfocusNode.requestFocus();
                                final isValid = context
                                    .read<SignUpProvider>()
                                    .validateForm(
                                      _emailController.text,
                                      _nameController.text,
                                      _passwordController.text,
                                    );
                                if (isValid) {
                                  // TODO: Proceed to Firebase registration logic
                                }
                              },
                              child: const Text(
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _navigateAndReset(() {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.push(
                                        AppRoutes.signInPath,
                                        extra: {'isPush': true},
                                      );
                                    }
                                  });
                                },
                                child: const Text(
                                  AuthConstants.signInButtonText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AuthConstants.spacingMedium),
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
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _unfocusNode.requestFocus();
                              },
                              icon: Image.asset(
                                AppAssets.googleLogo,
                                height: AuthConstants.iconSizeSmall,
                                width: AuthConstants.iconSizeSmall,
                              ),
                              label: Text(
                                AuthConstants.googleButtonText,
                                style: TextStyle(
                                  fontSize: AuthConstants.buttonTextSize,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
