import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../constants/home_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return HomeConstants.morningGreeting;
    } else if (hour < 17) {
      return HomeConstants.afternoonGreeting;
    } else {
      return HomeConstants.eveningGreeting;
    }
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '';
    return fullName.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName = _getFirstName(user?.displayName);
    final greetingText = firstName.isNotEmpty
        ? '${_getGreeting()},\n$firstName'
        : _getGreeting();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: HomeConstants.appBarToolbarHeight,
        title: Text(
          greetingText,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: HomeConstants.horizontalPadding,
            ),
            child: IconButton(
              icon: user?.photoURL != null
                  ? CircleAvatar(backgroundImage: NetworkImage(user!.photoURL!))
                  : CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondaryContainer,
                      child: Text(
                        firstName.isNotEmpty
                            ? firstName[0].toUpperCase()
                            : HomeConstants.fallbackAvatarText,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              onPressed: () {
                context.push(AppRoutes.profilePath);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: HomeConstants.flexCalendar,
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: const Center(
                child: Text(HomeConstants.placeholderCalendar),
              ),
            ),
          ),
          Expanded(
            flex: HomeConstants.flexEntries,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: const Center(
                child: Text(HomeConstants.placeholderEntries),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
