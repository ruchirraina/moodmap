import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/auth_constants.dart';
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
                              context
                                  .read<ForgotPasswordProvider>()
                                  .onEmailChanged(value);
                            },
                          ),
                          const SizedBox(height: AuthConstants.spacingLarge),
                          SizedBox(
                            height: AuthConstants.buttonHeight,
                            child: FilledButton(
                              onPressed: () {
                                _unfocusNode.requestFocus();
                                final isValid = context
                                    .read<ForgotPasswordProvider>()
                                    .validateForm(_emailController.text);
                                if (isValid) {
                                  context
                                      .read<ForgotPasswordProvider>()
                                      .showResetMessage();
                                }
                              },
                              child: const Text(
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
                            duration: const Duration(milliseconds: 300),
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
                                        padding: const EdgeInsets.all(
                                          AuthConstants.spacingMedium,
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
