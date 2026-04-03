// auth ui screen loads first a sign up screen/sign up screen
// uses PageView -> left sign up right sign in
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:moodmap/theme/theme_config.dart';
import 'package:moodmap/theme/theme_extension.dart';
import 'package:moodmap/screens/auth/input_validators.dart';
import 'package:moodmap/screens/auth/auth_logic.dart';

class AuthUi extends StatefulWidget {
  final bool loadSignUp; // load sign up/sign in?
  // default sign up
  const AuthUi({this.loadSignUp = true, super.key});

  @override
  State<AuthUi> createState() => _AuthUiState();
}

class _AuthUiState extends State<AuthUi> {
  // sign up email controller
  final TextEditingController _emailControllerSignUp = TextEditingController();
  // sign up email focus node
  final FocusNode _emailFocusNodeSignUp = FocusNode();

  // sign in email controller
  final TextEditingController _emailControllerSignIn = TextEditingController();
  // sign in email focus node
  final FocusNode _emailFocusNodeSignIn = FocusNode();

  // name controller (sign up only)
  final TextEditingController _nameController = TextEditingController();
  // name focus node (sign up only)
  final FocusNode _nameFocusNode = FocusNode();

  // sign up password controller
  final TextEditingController _passwordControllerSignUp =
      TextEditingController();
  // sign up password focus node
  final FocusNode _passwordFocusNodeSignUp = FocusNode();

  // sign in password controller
  final TextEditingController _passwordControllerSignIn =
      TextEditingController();
  // sign in password focus node
  final FocusNode _passwordFocusNodeSignIn = FocusNode();

  // clear sign up screen when focus is on sign up screen + clear errs
  void _onSignUpFieldFocus() {
    if (_emailFocusNodeSignUp.hasFocus ||
        _nameFocusNode.hasFocus ||
        _passwordFocusNodeSignUp.hasFocus) {
      _emailControllerSignIn.clear();
      _passwordControllerSignIn.clear();

      setState(() {
        _firebaseError = null;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  // clear sign up screen when focus is on sign in screen + clear errs
  void _onSignInFieldFocus() {
    if (_emailFocusNodeSignIn.hasFocus || _passwordFocusNodeSignIn.hasFocus) {
      _emailControllerSignUp.clear();
      _nameController.clear();
      _passwordControllerSignUp.clear();

      setState(() {
        _firebaseError = null;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  // toggles loading state of Continue Button
  bool _isContinueLoading = false;
  // toggle loading state of Google Button
  bool _isGoogleLoading = false;
  // recieve err msg if occurs
  String? _firebaseError;

  // signup continue handle
  void _onContinueSignUp() {
    // clear past errors
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() {
      _firebaseError = null;
    });
    // if input validation passed then
    if (_signUpFormKey.currentState?.validate() ?? false) {
      setState(() {
        // good ux to hide if was not
        _signUpObscurePassword = true;
        // toggle loading state
        _isContinueLoading = true;
      });
      // attempt sign up
      AuthLogic.signUpWithEmailPass(
        email: _emailControllerSignUp.text,
        password: _passwordControllerSignUp.text,
        name: _nameController.text,
      ).then((error) {
        if (mounted) {
          // no error good to go
          if (error == null) {
            context.go('/home');
          } // iff err for snackbar
          else if (!isErrorNotForSnackBar(error)) {
            // toggle loading state
            setState(() {
              _isContinueLoading = false;
            });
            // show SnackBar msg
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(context.errorSnackBar(error));
          } // for other errors display as field errors
          else {
            setState(() {
              _firebaseError = error;
              _isContinueLoading = false;
            });
          }
        }
      });
    }
  }

  // signin continue handle
  void _onContinueSignIn() {
    // clear past errors
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() {
      _firebaseError = null;
    });
    // if input validation passed then
    if (_signInFormKey.currentState?.validate() ?? false) {
      setState(() {
        // good ux to hide if was not
        _signInObscurePassword = true;
        // toggle loading state
        _isContinueLoading = true;
      });
      // attempt sign in
      AuthLogic.signInWithEmailPass(
        email: _emailControllerSignIn.text,
        password: _passwordControllerSignIn.text,
      ).then((error) {
        if (mounted) {
          // no error good to go
          if (error == null) {
            context.go('/home');
          } // iff err for snackbar
          else if (!isErrorNotForSnackBar(error)) {
            setState(() {
              _isContinueLoading = false;
            });
            // show SnackBar msg
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(context.errorSnackBar(error));
          } // for other errors display as field errors
          else {
            setState(() {
              _firebaseError = error;
              _isContinueLoading = false;
            });
          }
        }
      });
    }
  }

  void _onGoogleAuth() async {
    // clear past errors
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() {
      _isGoogleLoading = true;
      _firebaseError = null;
    });
    setState(() {
      // good ux to hide if was not
      _signInObscurePassword = true;
      _signUpObscurePassword = true;
    });
    // attempt google auth
    AuthLogic.googleAuth().then((error) {
      if (mounted) {
        // no error good to go
        if (error == null) {
          context.go('/home');
        } // iff err for snackbar
        else {
          // show SnackBar msg
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(context.errorSnackBar(error));
          setState(() {
            _isGoogleLoading = false;
          });
        }
      }
    });
  }

  late final PageController _pageController; // PageView controller

  @override
  void initState() {
    // load the right page
    _pageController = PageController(initialPage: widget.loadSignUp ? 0 : 1);
    _emailFocusNodeSignUp.addListener(_onSignUpFieldFocus);
    _emailFocusNodeSignIn.addListener(_onSignInFieldFocus);
    _nameFocusNode.addListener(_onSignUpFieldFocus);
    _passwordFocusNodeSignUp.addListener(_onSignUpFieldFocus);
    _passwordFocusNodeSignIn.addListener(_onSignInFieldFocus);
    super.initState();
  }

  // good habits :)
  @override
  void dispose() {
    super.dispose();
    _emailControllerSignUp.dispose();
    _emailFocusNodeSignUp.dispose();
    _emailControllerSignIn.dispose();
    _emailFocusNodeSignIn.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    _passwordControllerSignUp.dispose();
    _passwordFocusNodeSignUp.dispose();
    _passwordControllerSignIn.dispose();
    _passwordFocusNodeSignIn.dispose();
    _pageController.dispose();
  }

  // helper function to help in switching b/w sign up <-> sign in
  void _switchAuthMode() {
    // clear past errors
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() {
      _firebaseError = null;
    });
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

  // state for password obscurity for each form
  bool _signUpObscurePassword = true;
  bool _signInObscurePassword = true;

  @override
  Widget build(BuildContext context) {
    // to check if keyboard is up
    bool isKeyboardUp = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      // gotta protect so ui don't get cut
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(), // no scroll
          itemCount: 2,
          itemBuilder: (context, index) {
            // lazily build only the current and adjacent pages
            return _buildAuthPage(
              isKeyboardUp: isKeyboardUp,
              loadSignUp: index == 0,
            );
          },
        ),
      ),
    );
  }

  // helper widget that builds auth screen
  Widget _buildAuthPage({
    required bool isKeyboardUp,
    required bool loadSignUp,
  }) {
    // when tap outside form fields
    return GestureDetector(
      behavior: .opaque,
      onTap: () {
        if (loadSignUp) {
          _signUpObscurePassword = true;
        } else {
          _signInObscurePassword = true;
        }
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const .all(16), // feels right
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
            Text(
              (loadSignUp) ? 'Create an account to begin.' : 'Welcome Back!',
              style: context.textTheme.bodyMedium!.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),

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
                      Text(
                        'Email',
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // a small gap
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: loadSignUp
                            ? _emailControllerSignUp
                            : _emailControllerSignIn,
                        focusNode: loadSignUp
                            ? _emailFocusNodeSignUp
                            : _emailFocusNodeSignIn,
                        enabled: !(_isContinueLoading || _isGoogleLoading),
                        autovalidateMode: .onUserInteraction,
                        style: context.textTheme.bodyMedium,
                        // appropriate
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: .all(.circular(16)),
                          ),
                        ),
                        validator: (value) {
                          if (_firebaseError != null &&
                              isErrorForEmail(_firebaseError!)) {
                            return _firebaseError;
                          }
                          return emailInputValidator(value);
                        },
                      ),

                      // only for sign up screen -> Name Field
                      if (loadSignUp) ...[
                        // a proper gap
                        const SizedBox(height: 16),
                        Text(
                          'Your Name',
                          style: context.textTheme.bodyMedium!.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        // a small gap
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          enabled: !(_isContinueLoading || _isGoogleLoading),
                          autovalidateMode: .onUserInteraction,
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
                      Text(
                        (loadSignUp) ? 'Create Password' : 'Password',
                        style: context.textTheme.bodyMedium!.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      // a small gap
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: loadSignUp
                            ? _passwordControllerSignUp
                            : _passwordControllerSignIn,
                        focusNode: loadSignUp
                            ? _passwordFocusNodeSignUp
                            : _passwordFocusNodeSignIn,
                        enabled: !(_isContinueLoading || _isGoogleLoading),
                        autovalidateMode: .onUserInteraction,
                        style: context.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: .all(.circular(16)),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() {
                              if (loadSignUp) {
                                _signUpObscurePassword =
                                    !_signUpObscurePassword;
                              } else {
                                _signInObscurePassword =
                                    !_signInObscurePassword;
                              }
                            }),
                            icon: Icon(
                              (loadSignUp
                                      ? _signUpObscurePassword
                                      : _signInObscurePassword)
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        obscureText: loadSignUp
                            ? _signUpObscurePassword
                            : _signInObscurePassword,
                        validator: (value) {
                          if (_firebaseError != null &&
                              isErrorForPassword(_firebaseError!)) {
                            return _firebaseError;
                          }
                          return passwordInputValidator(value, loadSignUp);
                        },
                      ),

                      // only for sign in screen -> forgot password button
                      if (!loadSignUp) ...[
                        // a small gap
                        const SizedBox(height: 4),
                        Opacity(
                          opacity: (_isContinueLoading || _isGoogleLoading)
                              ? 0.5
                              : 1,
                          child: TextButton(
                            onPressed: (_isContinueLoading || _isGoogleLoading)
                                ? null
                                : () => context.push('/passReset'),
                            child: Text(
                              'Forgot Password?',
                              // feels right
                              style: context.textTheme.bodySmall!.copyWith(
                                color: context.colorScheme.tertiary,
                                fontWeight: .bold,
                              ),
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
                        child: IgnorePointer(
                          ignoring: (_isContinueLoading || _isGoogleLoading),
                          child: FilledButton(
                            onPressed: loadSignUp
                                ? _onContinueSignUp
                                : _onContinueSignIn,
                            style: FilledButton.styleFrom(
                              backgroundColor: context.colorScheme.primary
                                  .withValues(
                                    alpha:
                                        (_isContinueLoading || _isGoogleLoading)
                                        ? 0.75
                                        : 1,
                                  ),
                              // borderRadius consistency
                              shape: RoundedRectangleBorder(
                                borderRadius: .all(.circular(16)),
                              ),
                            ),
                            child: _isContinueLoading
                                ? SpinKitThreeInOut(
                                    color: context.colorScheme.onSecondary,
                                    size: 50,
                                  )
                                : Text(
                                    'Continue',
                                    style: ThemeConfig.buttonTextTheme(context),
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
                            ? Opacity(
                                opacity:
                                    (_isContinueLoading || _isGoogleLoading)
                                    ? 0.5
                                    : 1,
                                child: Row(
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
                                      onPressed:
                                          (_isContinueLoading ||
                                              _isGoogleLoading)
                                          ? null
                                          : _switchAuthMode,
                                      // make it feel part of text
                                      style: TextButton.styleFrom(
                                        padding: .all(0),
                                      ),
                                      child: Text(
                                        // conditional button text
                                        (loadSignUp) ? 'Sign In' : 'Sign Up',
                                        // feels right
                                        style: context.textTheme.bodySmall!
                                            .copyWith(
                                              color:
                                                  context.colorScheme.primary,
                                              fontWeight: .bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
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
                          child: IgnorePointer(
                            ignoring: (_isContinueLoading || _isGoogleLoading),
                            child: ElevatedButton.icon(
                              onPressed: _onGoogleAuth,
                              style: FilledButton.styleFrom(
                                backgroundColor: context
                                    .colorScheme
                                    .surfaceContainerLow
                                    .withValues(
                                      alpha:
                                          (_isContinueLoading ||
                                              _isGoogleLoading)
                                          ? 0.75
                                          : 1,
                                    ),
                                // borderRadius consistency
                                shape: RoundedRectangleBorder(
                                  borderRadius: .all(.circular(16)),
                                ),
                              ),
                              // google logo
                              icon: !_isGoogleLoading
                                  ? Opacity(
                                      opacity: _isContinueLoading ? 0.25 : 1,
                                      child: Image.asset(
                                        'assets/auth_google/google.png',
                                        // feels right
                                        height: 20,
                                        width: 20,
                                      ),
                                    )
                                  : null,
                              label: _isGoogleLoading
                                  ? SpinKitThreeInOut(
                                      color: context.colorScheme.onSurface,
                                      size: 50,
                                    )
                                  : Opacity(
                                      opacity: _isContinueLoading ? 0.5 : 1,
                                      child: Text(
                                        'Continue with Google',
                                        style: context.textTheme.bodyLarge!
                                            .copyWith(
                                              color:
                                                  context.colorScheme.onSurface,
                                              fontWeight: .w500,
                                            ),
                                      ),
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
      ),
    );
  }
}
