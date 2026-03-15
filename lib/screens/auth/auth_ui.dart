// auth ui screen loads first a sign up screen/sign up screen
// uses PageView -> left sign up right sign in
import 'package:flutter/material.dart';
import 'package:moodmap/theme/theme_extension.dart';
import 'package:moodmap/screens/auth/input_validators.dart';

class AuthUi extends StatefulWidget {
  final bool loadSignUp; // load sign up/sign in?
  // default sign up
  const AuthUi({this.loadSignUp = true, super.key});

  @override
  State<AuthUi> createState() => _AuthUiState();
}

class _AuthUiState extends State<AuthUi> {
  late final PageController _pageController; // PageView controller

  @override
  void initState() {
    // load the right page
    _pageController = PageController(initialPage: widget.loadSignUp ? 0 : 1);
    super.initState();
  }

  // good habits :)
  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  // helper function to help in switching b/w sign up <-> sign in
  void _switchAuthMode() {
    // go to sign in screen if at sign up screen
    if (_pageController.page == 0) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 500), // feels right
        curve: Curves.fastOutSlowIn, // feels right
      );
    } // go to sign up screen if at sign in screen
    else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 500), // feels right
        curve: Curves.fastOutSlowIn, // feels right
      );
    }
  }

  // two global keys for form validation
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // to check if keyboard is up
    bool isisKeyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      // gotta protect so ui don't get cut
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(), // no scroll
          children: [
            // sign up screen
            _buildAuthPage(isKeyboardUp: isisKeyboardUp, loadSignUp: true),
            // sign in screen
            _buildAuthPage(isKeyboardUp: isisKeyboardUp, loadSignUp: false),
          ],
        ),
      ),
    );
  }

  // helper widget that builds auth screen
  Widget _buildAuthPage({
    required bool isKeyboardUp,
    required bool loadSignUp,
  }) {
    return Padding(
      padding: const .all(16), // feels right
      // a regular column works
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // feels right
        children: [
          Text(
            // conditional top text
            (loadSignUp) ? 'Sign Up' : 'Sign In',
            style: context.textTheme.displayLarge!.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
          // a small gap
          const SizedBox(height: 16),
          // conditional subtitle
          Text((loadSignUp) ? 'Create an account to begin.' : 'Welcome Back!'),

          // scrollable section even if cut off by keyboard
          Expanded(
            child: SingleChildScrollView(
              // regular column works here too
              child: Form(
                // conditional form key
                key: loadSignUp ? _signUpFormKey : _signInFormKey,
                child: Column(
                  crossAxisAlignment: .start, // feels right
                  children: [
                    // a proper gap
                    const SizedBox(height: 32),
                    // email area
                    const Text('Email'),
                    // a small gap
                    const SizedBox(height: 4),
                    TextFormField(
                      style: context.textTheme.bodyMedium,
                      // appropriate
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: .all(.circular(16)),
                        ),
                      ),
                      validator: (value) => emailInputValidator(value),
                    ),

                    // only for sign up screen -> Name Field
                    if (loadSignUp) ...[
                      // a proper gap
                      const SizedBox(height: 16),
                      const Text('Your Name'),
                      // a small gap
                      const SizedBox(height: 4),
                      TextFormField(
                        style: context.textTheme.bodyMedium,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: .all(.circular(16)),
                          ),
                        ),
                        validator: (value) => nameInputValidator(value),
                      ),
                    ],

                    // a proper gap
                    const SizedBox(height: 16),
                    // conditional TextFormField top text
                    Text((loadSignUp) ? 'Create Password' : 'Password'),
                    // a small gap
                    const SizedBox(height: 4),
                    TextFormField(
                      style: context.textTheme.bodyMedium,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: .all(.circular(16)),
                        ),
                      ),
                      validator: (value) =>
                          passwordInputValidator(value, loadSignUp),
                    ),

                    // only for sign in screen -> forgot password button
                    if (!loadSignUp) ...[
                      // a small gap
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {}, // non functional rn
                        child: Text(
                          'Forgot Password?',
                          // feels right
                          style: context.textTheme.bodySmall!.copyWith(
                            color: context.colorScheme.tertiary,
                            fontWeight: .bold,
                          ),
                        ),
                      ),
                    ],

                    // a medium gap
                    const SizedBox(height: 24),
                    // continue button
                    SizedBox(
                      // height consistency with other button
                      height: 50,
                      width: .infinity, // a wide button
                      child: FilledButton(
                        // just performs input validation for now
                        onPressed: () {
                          if (loadSignUp) {
                            _signUpFormKey.currentState?.validate();
                          } else {
                            _signInFormKey.currentState?.validate();
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colorScheme.secondary,
                          // borderRadius consistency
                          shape: RoundedRectangleBorder(
                            borderRadius: .all(.circular(16)),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: context.textTheme.bodyLarge!.copyWith(
                            color: context.colorScheme.onSecondary,
                            fontWeight: .bold,
                          ),
                        ),
                      ),
                    ),

                    // a medium gap | also a buffer between keyboard and continue
                    const SizedBox(height: 16),
                    // hide if keyboard
                    AnimatedSwitcher(
                      // pretty quick
                      duration: const Duration(milliseconds: 250),
                      // feel right
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeOut,
                      child: (!isKeyboardUp)
                          // switch to sign in/sign up
                          ? Row(
                              mainAxisAlignment: .center, // feels right
                              children: [
                                Text(
                                  (loadSignUp)
                                      ? 'Already have an account?'
                                      : 'New here?',
                                  // feels right
                                  style: context.textTheme.bodySmall,
                                ),
                                TextButton(
                                  onPressed: _switchAuthMode,
                                  // make it feel part of text
                                  style: TextButton.styleFrom(padding: .all(0)),
                                  child: Text(
                                    // conditional button text
                                    (loadSignUp) ? 'Sign In' : 'Sign Up',
                                    // feels right
                                    style: context.textTheme.bodySmall!
                                        .copyWith(
                                          color: context.colorScheme.primary,
                                          fontWeight: .bold,
                                        ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(), // better than other ways
                    ),
                  ],
                ),
              ),
            ),
          ),

          // squished to bottom bc above widget is expanded
          // hide if keyboard
          // a alt auth method
          AnimatedSwitcher(
            // pretty quick
            duration: const Duration(milliseconds: 250),
            // feels right
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeOut,
            child: (!isKeyboardUp)
                // regular column works
                ? Column(
                    children: [
                      // 'Or' with two dividers on either side
                      Row(
                        children: [
                          // divider on left
                          Expanded(
                            child: Opacity(
                              opacity: 0.5, // feels right
                              child: Divider(
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          // 'Or'
                          Padding(
                            padding: const .symmetric(horizontal: 8),
                            child: Opacity(
                              opacity: 0.75, //feels right
                              child: Text('Or'),
                            ),
                          ),
                          // divider on right
                          Expanded(
                            child: Opacity(
                              opacity: 0.5, // feels right
                              child: Divider(
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // a medium gap
                      const SizedBox(height: 20),
                      // continue with google button
                      SizedBox(
                        // height consistency with other button
                        height: 50,
                        width: .infinity, // a wide button
                        child: ElevatedButton.icon(
                          onPressed: () {}, // non functional rn
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: .all(.circular(16)),
                            ),
                            // preventing splash holding when google overlay up
                            splashFactory: NoSplash.splashFactory,
                          ),
                          // google logo
                          icon: Image.asset(
                            'assets/auth_google/google.png',
                            // feels right
                            height: 25,
                            width: 25,
                          ),
                          label: Text(
                            'Continue with Google',
                            style: context.textTheme.bodyLarge!.copyWith(
                              fontWeight: .bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(), // better than other ways
          ),
        ],
      ),
    );
  }
}
