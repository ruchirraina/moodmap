class AuthConstants {
  static const double horizontalPadding = 24.0;
  static const double verticalPadding = 48.0;
  static const double spacingTiny = 8.0;
  static const double spacingSmall = 16.0;
  static const double spacingMedium = 24.0;
  static const double spacingLarge = 32.0;
  static const double buttonHeight = 56.0;
  static const double borderRadius = 24.0;
  static const double inputVerticalPadding = 16.0;
  static const double iconSizeSmall = 24.0;
  static const double borderWidth = 2.0;
  static const double suffixIconPadding = 8.0;
  static const double buttonTextSize = 16.0;

  static const int navigateResetDelayMs = 500;
  static const int nameMaxLength = 50;
  static const int passwordMinLength = 6;

  static const String signUpTitleText = 'Create Account';
  static const String signInTitleText = 'Welcome Back';
  static const String forgotPasswordTitleText = 'Reset your password';
  static const String emailLabel = 'Email';
  static const String nameLabel = 'Your Name';
  static const String passwordCreateLabel = 'Create Password';
  static const String passwordEnterLabel = 'Enter Password';
  static const String continueButtonText = 'Continue';
  static const String sendResetLinkButtonText = 'Send Reset Link';
  static const String existingAccountText = 'Already have an account?';
  static const String newAccountText = 'Are you new here?';
  static const String signInButtonText = 'Sign In';
  static const String signUpButtonText = 'Sign Up';
  static const String forgotPasswordText = 'Forgot Password?';
  static const String googleButtonText = 'Continue with Google';
  static const String orText = 'or';

  static const String resetNoteTitle = 'What to know about password resets';
  static const String resetNotePoint1 =
      'We will send a secure link to your email address.';
  static const String resetNotePoint2 =
      'The link expires after a short period of time.';
  static const String resetNotePoint3 =
      'Check your spam folder if you do not see it.';

  static const String emptyEmailError = 'Email cannot be empty';
  static const String emptyNameError = 'Name cannot be empty';
  static const String nameLengthError = 'Name cannot exceed 50 characters';
  static const String emptyPasswordError = 'Password cannot be empty';
  static const String passwordLengthError =
      'Password must be at least 6 characters';
  static const String emailInUseError = 'Email already in use';
  static const String invalidCredentialsError = 'Invalid email or password';
  static const String resetLinkSentMessage =
      'Reset link sent to email if linked to MoodMap.';
}
