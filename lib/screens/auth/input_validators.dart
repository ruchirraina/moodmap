// auth form input validators

// validation so as to not allow empty fields
// auth credentials handeled by firebase
// if already in use email check done by firebase
String? emailInputValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Your email can't be empty!";
  }
  return null;
}

// validation so as to not allow empty fields
String? nameInputValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Your name can't be empty!";
  } else if (value.length > 50) {
    return "Your name can't be longer longer than a 50 charachters!";
  }
  return null;
}

// validation so as to not allow empty fields
String? passwordInputValidator(String? value, bool loadSignUp) {
  if (loadSignUp == true &&
      ((value == null || value.isEmpty || value.length < 6))) {
    return 'Your password must be at least 6 charachters long!';
  } else if (loadSignUp == false && (value == null || value.isEmpty)) {
    return " Your password can't be empty!";
  }

  return null;
}

// err msgs that don't make sense to display as SnackBar messages
bool isErrorNotForSnackBar(String errorMessage) =>
    (errorMessage.contains('email is invalid') ||
    errorMessage.contains('email is already in use') ||
    errorMessage.contains('password is too weak') ||
    errorMessage.contains('Incorrect email or password'));

// err msgs that make sense for email field
bool isErrorForEmail(String errorMessage) =>
    (errorMessage.contains('email is invalid') ||
    errorMessage.contains('email is already in use') ||
    errorMessage.contains('Incorrect email or password'));

// err msgs that make sense for email field
bool isErrorForPassword(String errorMessage) =>
    (errorMessage.contains('password is too weak') ||
    errorMessage.contains('Incorrect email or password'));
