// auth form input validators

// validation so as to not allow empty fields
// auth credentials handeled by firebase
// if already in use email check done by firebase
String? emailInputValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Email field can't be empty!";
  }
  return null;
}

// validation so as to not allow empty fields
String? nameInputValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Your name can't be empty!";
  } else if (value.length > 100) {
    return "Your name can't be longer longer than 100 charachters!";
  }
  return null;
}

// validation so as to not allow empty fields
String? passwordInputValidator(String? value, bool loadSignUp) {
  if (loadSignUp == true && (value == null || value.isEmpty)) {
    return 'Password must be at least 6 charachters long!';
  } else if (loadSignUp == false &&
      (value == null || value.isEmpty || value.length < 6)) {
    return "Password field can't be empty!";
  }
  return null;
}
