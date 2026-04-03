import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moodmap/theme/theme_config.dart';
import 'package:moodmap/theme/theme_extension.dart';
import 'package:moodmap/screens/auth/input_validators.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:moodmap/screens/auth/auth_logic.dart';

class PassReset extends StatefulWidget {
  const PassReset({super.key});

  @override
  State<PassReset> createState() => _PassResetState();
}

class _PassResetState extends State<PassReset> {
  // toggle loading state
  bool _isLoading = false;

  // TextEditingController for email field
  final TextEditingController _emailController = TextEditingController();

  // FocusNode for email field
  final FocusNode _emailFocusNode = FocusNode();

  // global key for form validation
  final GlobalKey<FormState> _passResetFormKey = GlobalKey<FormState>();

  // recieve err msg if occurs
  String? _firebaseError;

  // handle button press
  void _onButtonPress() async {
    // clear past errors
    setState(() {
      _firebaseError = null;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    // if input validation passed then
    if (_passResetFormKey.currentState?.validate() ?? false) {
      setState(() {
        // toggle loading state
        _isLoading = true;
      });
      await AuthLogic.forgotPassword(email: _emailController.text).then((
        error,
      ) {
        if (error != null && !isErrorNotForSnackBar(error)) {
          // show SnackBar msg
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              ThemeConfig.errorSnackBar(
                context,
                errorMessage: error,
                bottomMargin: 200,
              ),
            );
          }
        } else if (error != null && isErrorForEmail(error)) {
          setState(() {
            _firebaseError = error;
          });
        }
      });
      setState(() {
        // toggle loading state
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: .floating,
            // feels right utilising empty space
            margin: .only(bottom: 200, left: 16, right: 16),
            backgroundColor: context.colorScheme.surfaceContainerLow,
            elevation: 0.75,
            // feels right
            dismissDirection: .horizontal,
            persist: true, // stays
            content: Text(
              'A password reset link has been sent to email (if linked to MoodMap).',
              // feels right
              style: context.textTheme.labelMedium!.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: .bold,
              ),
            ),
          ),
        );
      });
    }
  }

  // clear errors when focus is on email field
  void _onFieldFocus() {
    if (_emailFocusNode.hasFocus) {
      // clear errors
      setState(() {
        _firebaseError = null;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  @override
  void initState() {
    super.initState();
    // add listener to email focus node
    _emailFocusNode.addListener(_onFieldFocus);
  }

  @override
  Widget build(BuildContext context) {
    // to check if keyboard is up
    bool isKeyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // back button
        leading: IconButton(
          onPressed: () {
            context.pop();
            // clear errors
            setState(() {
              _firebaseError = null;
            });
            ScaffoldMessenger.of(context).clearSnackBars();
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      // gotta protect so ui don't get cut
      body: SafeArea(
        child: GestureDetector(
          // when tap outside form fields
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: .opaque,
          child: Padding(
            padding: const .only(bottom: 16, left: 16, right: 16),
            child: Column(
              mainAxisAlignment: .spaceBetween,
              children: [
                Form(
                  key: _passResetFormKey,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'Reset Password',
                        style: context.textTheme.displayMedium!.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'PlayfairDisplay',
                        ),
                      ),
                      // a proper gap
                      const SizedBox(height: 24),
                      Text(
                        'Enter your email to reset your password.',
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // a small gap
                      TextFormField(
                        autovalidateMode: .onUserInteraction,
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        enabled: !_isLoading,
                        style: context.textTheme.bodyMedium,
                        // appropriate
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: .all(.circular(16)),
                          ),
                        ),
                        validator: (value) {
                          if (_firebaseError != null) {
                            return _firebaseError;
                          }
                          return emailInputValidator(value);
                        },
                      ),
                      // a medium gap
                      const SizedBox(height: 24),
                      // send button
                      SizedBox(
                        // height consistency with other button
                        height: 50,
                        width: .infinity, // a wide button
                        child: IgnorePointer(
                          ignoring: _isLoading,
                          child: FilledButton(
                            // just performs input validation for now
                            onPressed: _onButtonPress,
                            style: FilledButton.styleFrom(
                              backgroundColor: context.colorScheme.primary
                                  .withValues(alpha: _isLoading ? 0.75 : 1),
                              // borderRadius consistency
                              shape: RoundedRectangleBorder(
                                borderRadius: .all(.circular(16)),
                              ),
                            ),
                            child: _isLoading
                                ? SpinKitThreeInOut(
                                    color: context.colorScheme.onPrimary,
                                    size: 50,
                                  )
                                : Text(
                                    'Send Reset Link',
                                    style: ThemeConfig.buttonTextTheme(context),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // note about password reset for users
                // hide if keyboard
                AnimatedSwitcher(
                  // pretty quick
                  duration: const Duration(milliseconds: 250),
                  // feels right
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeOut,
                  child: (!isKeyboardUp)
                      ? SizedBox(
                          key: const ValueKey('password_reset_note'),
                          width: .infinity,
                          child: Card(
                            child: Padding(
                              padding: .all(16),
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: context.colorScheme.tertiary,
                                      ),
                                      // a small gap
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'What to know about password resets?',
                                          style: context.textTheme.bodyLarge!
                                              .copyWith(
                                                color: context
                                                    .colorScheme
                                                    .tertiary,
                                                fontWeight: .bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: context
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      // a small gap
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Resetting your password will log you out of all other devices.',
                                          style: context.textTheme.labelMedium!
                                              .copyWith(
                                                color: context
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: context
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      // a small gap
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'The reset link in your email will expire in 1 hour.',
                                          style: context.textTheme.labelMedium!
                                              .copyWith(
                                                color: context
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: context
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      // a small gap
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Each link works only once for your security.',
                                          style: context.textTheme.labelMedium!
                                              .copyWith(
                                                color: context
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
