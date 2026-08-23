import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../constants/auth_constants.dart';
import '../../../../core/constants/app_animations.dart';
import '../../../../core/widgets/shake_widget.dart';
import '../providers/forgot_password_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (mounted) {
        context.read<ForgotPasswordProvider>().onEmailFocusChanged(
          _emailFocusNode.hasFocus,
          _emailController.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _unfocusNode.dispose();
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String label,
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
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForgotPasswordProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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
                            AuthConstants.forgotPasswordTitleText,
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
                              enabled: !provider.isLoading,
                              decoration: _buildInputDecoration(
                                context,
                                label: AuthConstants.emailLabel,
                                errorText: provider.emailError,
                              ),
                              onChanged: (value) {
                                context
                                    .read<ForgotPasswordProvider>()
                                    .onEmailChanged(value);
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
                                    .secondary,
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSecondary,
                              ),
                              onPressed: provider.isLoading
                                  ? null
                                  : () async {
                                      _unfocusNode.requestFocus();
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      await context
                                          .read<ForgotPasswordProvider>()
                                          .sendResetLink(_emailController.text);
                                    },
                              child: provider.isLoading
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
                                      AuthConstants.sendResetLinkButtonText,
                                      style: TextStyle(
                                        fontSize: AuthConstants.buttonTextSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: AuthConstants.spacingLarge),
                          const Spacer(),
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
                                            .read<ForgotPasswordProvider>()
                                            .clearGenericError();
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              AuthConstants.spacingMedium,
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
                          AnimatedSize(
                            duration: AppAnimations.animatedSizeDuration,
                            curve: Curves.easeInOut,
                            child: provider.isResetMessageVisible
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AuthConstants.spacingMedium,
                                    ),
                                    child: Dismissible(
                                      key: const Key('reset_message'),
                                      onDismissed: (_) {
                                        context
                                            .read<ForgotPasswordProvider>()
                                            .hideResetMessage();
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              AuthConstants.spacingMedium,
                                          vertical: AuthConstants.spacingSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            AuthConstants.borderRadius,
                                          ),
                                        ),
                                        child: Text(
                                          AuthConstants.resetLinkSentMessage,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          Card(
                            elevation: 0,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AuthConstants.borderRadius,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AuthConstants.spacingSmall,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AuthConstants.resetNoteTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: AuthConstants.spacingSmall,
                                  ),
                                  _buildBulletPoint(
                                    context,
                                    AuthConstants.resetNotePoint1,
                                  ),
                                  const SizedBox(
                                    height: AuthConstants.spacingTiny,
                                  ),
                                  _buildBulletPoint(
                                    context,
                                    AuthConstants.resetNotePoint2,
                                  ),
                                  const SizedBox(
                                    height: AuthConstants.spacingTiny,
                                  ),
                                  _buildBulletPoint(
                                    context,
                                    AuthConstants.resetNotePoint3,
                                  ),
                                ],
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
