import '../constants/app_constants.dart';

class LoadingUtils {
  static Future<void> enforceMinimumLoadTime(DateTime startTime) async {
    final elapsedTime = DateTime.now().difference(startTime);
    if (elapsedTime.inMilliseconds < AppConstants.minimumLoadingMs) {
      await Future.delayed(
        Duration(
          milliseconds:
              AppConstants.minimumLoadingMs - elapsedTime.inMilliseconds,
        ),
      );
    }
  }
}
