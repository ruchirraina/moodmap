import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/constants/app_routes.dart';
import '../../constants/home_constants.dart';
import '../../../journal/presentation/providers/journal_provider.dart';
import '../../../journal/domain/models/journal_entry.dart';
import '../providers/home_provider.dart';
import '../widgets/entry_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController? _pageController;
  bool _isAudioMuted = true;
  double _contentOpacity = 1.0;
  bool _isTransitioning = false;
  final Key _pageViewKey = const ValueKey('initial_page_view');

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

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

  DateTime _normalizeDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  List<DateTime> _getNavigableDates(JournalProvider provider) {
    final dates = provider.entries
        .map((e) => _normalizeDate(e.date))
        .toSet()
        .toList();

    final today = _normalizeDate(DateTime.now());
    if (!dates.contains(today)) {
      dates.add(today);
    }

    dates.sort((a, b) => a.compareTo(b));
    return dates;
  }

  void _showDeleteDialog(BuildContext context, JournalEntry entry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: HomeConstants.overlayAlpha),
      builder: (dialogContext) {
        bool isDeleting = false;
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: HomeConstants.dialogBlurSigma,
            sigmaY: HomeConstants.dialogBlurSigma,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    HomeConstants.entryCardRadius,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(HomeConstants.dialogPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        HomeConstants.deleteDialogTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: HomeConstants.spacingMedium),
                      Text(
                        HomeConstants.deleteDialogBody,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: HomeConstants.spacingLarge),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: HomeConstants.dialogButtonHeight,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isDeleting
                                        ? Theme.of(context).colorScheme.tertiary
                                              .withValues(
                                                alpha: HomeConstants
                                                    .disabledBorderAlpha,
                                              )
                                        : Theme.of(context)
                                              .colorScheme
                                              .tertiary,
                                  ),
                                  foregroundColor: isDeleting
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.tertiary.withValues(
                                          alpha:
                                              HomeConstants.disabledTextAlpha,
                                        )
                                      : Theme.of(context).colorScheme.tertiary,
                                ),
                                onPressed: isDeleting
                                    ? null
                                    : () => Navigator.pop(dialogContext),
                                child: const Text(
                                  HomeConstants.cancelText,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: HomeConstants.spacingMedium),
                          Expanded(
                            child: SizedBox(
                              height: HomeConstants.dialogButtonHeight,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .error,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: isDeleting
                                    ? null
                                    : () async {
                                        setState(() => isDeleting = true);
                                        await Future.delayed(
                                          const Duration(
                                            milliseconds:
                                                HomeConstants.dialogDelayMs,
                                          ),
                                        );
                                        if (dialogContext.mounted) {
                                          Navigator.pop(dialogContext);
                                          dialogContext
                                              .read<JournalProvider>()
                                              .deleteEntry(entry.id);
                                        }
                                      },
                                child: isDeleting
                                    ? SpinKitThreeBounce(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(
                                              alpha: HomeConstants
                                                  .disabledTextAlpha,
                                            ),
                                        size: HomeConstants.iconSizeSmall,
                                      )
                                    : const Text(
                                        HomeConstants.deleteText,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    final homeProvider = context.watch<HomeProvider>();

    final navigableDates = _getNavigableDates(provider);
    final selectedDate = _normalizeDate(provider.selectedDate);
    final targetPageIndex = navigableDates.indexOf(selectedDate);

    if (provider.isInitialized && _pageController == null) {
      _pageController = PageController(
        initialPage: targetPageIndex != -1 ? targetPageIndex : 0,
      );
    }

    final firstName = _getFirstName(homeProvider.displayName);
    final greetingText = firstName.isNotEmpty
        ? '${_getGreeting()},\n$firstName'
        : _getGreeting();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: HomeConstants.appBarToolbarHeight,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              icon: homeProvider.photoURL != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(homeProvider.photoURL!),
                    )
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
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: HomeConstants.horizontalPadding,
              vertical: HomeConstants.calendarMarginVertical,
            ),
            padding: const EdgeInsets.all(HomeConstants.calendarPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(
                HomeConstants.entryCardRadius,
              ),
            ),
            child: TableCalendar(
              firstDay: navigableDates.isNotEmpty
                  ? navigableDates.first
                  : selectedDate,
              lastDay: _normalizeDate(DateTime.now()),
              focusedDay: selectedDate,
              currentDay: _normalizeDate(DateTime.now()),
              selectedDayPredicate: (day) =>
                  _normalizeDate(day) == selectedDate,
              calendarFormat: CalendarFormat.week,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
                selectedTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontWeight: FontWeight.bold,
                ),
                defaultTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                disabledTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant
                      .withValues(alpha: HomeConstants.disabledTextAlpha),
                ),
                outsideTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant
                      .withValues(alpha: HomeConstants.disabledTextAlpha),
                ),
              ),
              enabledDayPredicate: (day) {
                return navigableDates.contains(_normalizeDate(day));
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (_isTransitioning) return;

                final normalized = _normalizeDate(selectedDay);
                if (navigableDates.contains(normalized)) {
                  final targetIndex = navigableDates.indexOf(normalized);
                  final currentIndex = _pageController?.hasClients == true
                      ? _pageController!.page!.round()
                      : (_pageController?.initialPage ?? 0);
                  final delta = (targetIndex - currentIndex).abs();

                  if (delta > 1) {
                    setState(() {
                      _isTransitioning = true;
                      _contentOpacity = 0.0;
                    });

                    Future.delayed(
                      const Duration(
                        milliseconds: HomeConstants.pageAnimationDurationMs,
                      ),
                      () {
                        if (mounted) {
                          _pageController?.jumpToPage(targetIndex);
                          provider.setSelectedDate(normalized);
                          setState(() {
                            _contentOpacity = 1.0;
                            _isTransitioning = false;
                          });
                        }
                      },
                    );
                  } else {
                    provider.setSelectedDate(normalized);
                    _pageController?.animateToPage(
                      targetIndex,
                      duration: const Duration(
                        milliseconds: HomeConstants.pageAnimationDurationMs,
                      ),
                      curve: Curves.easeInOut,
                    );
                  }
                }
              },
            ),
          ),
          Expanded(
            child: !provider.isInitialized || _pageController == null
                ? Center(
                    child: SpinKitThreeBounce(
                      color: Theme.of(context).colorScheme.primary,
                      size: HomeConstants.iconSizeMedium,
                    ),
                  )
                : AnimatedOpacity(
                    opacity: _contentOpacity,
                    duration: const Duration(
                      milliseconds: HomeConstants.pageAnimationDurationMs,
                    ),
                    curve: Curves.easeInOut,
                    child: PageView.builder(
                      key: _pageViewKey,
                      controller: _pageController,
                      physics: _isTransitioning
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
                      itemCount: navigableDates.length,
                      onPageChanged: (index) {
                        final newDate = navigableDates[index];
                        if (provider.selectedDate != newDate) {
                          provider.setSelectedDate(newDate);
                        }
                      },
                      itemBuilder: (context, index) {
                        final date = navigableDates[index];
                        final isToday = date == _normalizeDate(DateTime.now());
                        final entry = provider.entries
                            .where((e) => _normalizeDate(e.date) == date)
                            .firstOrNull;

                        if (entry == null && isToday) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  HomeConstants.emptyTodayText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(
                                  height: HomeConstants.spacingMedium,
                                ),
                                FloatingActionButton.large(
                                  onPressed: () {
                                    context.push(
                                      AppRoutes.composerPath,
                                      extra: {AppRoutes.argEntryDate: date},
                                    );
                                  },
                                  child: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          );
                        }

                        if (entry == null) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: HomeConstants.spacingMedium,
                          ),
                          child: EntryCard(
                            entry: entry,
                            isMuted: _isAudioMuted,
                            onToggleMute: () {
                              setState(() {
                                _isAudioMuted = !_isAudioMuted;
                              });
                            },
                            onDelete: () => _showDeleteDialog(context, entry),
                            onEdit: () {
                              context.push(
                                AppRoutes.composerPath,
                                extra: {
                                  AppRoutes.argEntryDate: date,
                                  AppRoutes.argExistingEntry: entry,
                                },
                              );
                            },
                            onExpand: () {
                              context.push(
                                AppRoutes.expandedEntryPath,
                                extra: {AppRoutes.argExistingEntry: entry},
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
