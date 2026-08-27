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
import '../../../music/presentation/providers/audio_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/journal_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController? _pageController;
  double _contentOpacity = 1.0;
  bool _isTransitioning = false;
  final Key _pageViewKey = const ValueKey('initial_page_view');

  JournalProvider? _journalProvider;
  String? _lastPlayedUrl;
  bool _hasInitializedAudio = false;

  DateTime? _focusedDay;
  DateTime? _lastSelectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _journalProvider = context.read<JournalProvider>();
        _journalProvider?.addListener(_syncAudio);
        _syncAudio();
      }
    });
  }

  @override
  void dispose() {
    _journalProvider?.removeListener(_syncAudio);
    _pageController?.dispose();
    super.dispose();
  }

  void _syncAudio() {
    if (!mounted) return;
    final provider = _journalProvider;
    if (provider != null && provider.isInitialized) {
      final entry = provider.entryForSelectedDate;
      final url = entry?.songPreviewUrl;
      if (!_hasInitializedAudio || _lastPlayedUrl != url) {
        _hasInitializedAudio = true;
        _lastPlayedUrl = url;
        context.read<AudioProvider>().setGlobalTrack(url);
      }
    }
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

  DateTime _getStartOfWeek(DateTime date) {
    final normalized = _normalizeDate(date);
    final int daysToSubtract = normalized.weekday == 7 ? 0 : normalized.weekday;
    return normalized.subtract(Duration(days: daysToSubtract));
  }

  DateTime _getEndOfWeek(DateTime date) {
    return _getStartOfWeek(date).add(const Duration(days: 6));
  }

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

  Widget _buildEmptyStateLoader(BuildContext context) {
    return Align(
      alignment: const Alignment(0.0, HomeConstants.emptyStateAlignmentY),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.0,
            child: Text(
              HomeConstants.emptyTodayText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: HomeConstants.spacingMedium),
          SizedBox(
            height: HomeConstants.emptyStateFabHeight,
            width: HomeConstants.emptyStateFabHeight,
            child: Center(
              child: SpinKitThreeBounce(
                color: Theme.of(context).colorScheme.primary,
                size: HomeConstants.iconSizeMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    final homeProvider = context.watch<HomeProvider>();
    final audioProvider = context.watch<AudioProvider>();

    final navigableDates = _getNavigableDates(provider);
    final selectedDate = _normalizeDate(provider.selectedDate);
    final targetPageIndex = navigableDates.indexOf(selectedDate);

    final earliestDate = navigableDates.isNotEmpty
        ? navigableDates.first
        : selectedDate;
    final firstCalendarDay = _getStartOfWeek(earliestDate);
    final today = _normalizeDate(DateTime.now());
    final lastCalendarDay = _getEndOfWeek(today);

    if (_lastSelectedDate != selectedDate) {
      _focusedDay = selectedDate;
      _lastSelectedDate = selectedDate;
    }

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
              icon: CircleAvatar(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .secondaryContainer,
                child: ClipOval(
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      ),
                      if (homeProvider.photoURL != null &&
                          homeProvider.photoURL!.isNotEmpty)
                        Image.network(
                          homeProvider.photoURL!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                    ],
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
              key: ValueKey(firstCalendarDay),
              firstDay: firstCalendarDay,
              lastDay: lastCalendarDay,
              focusedDay: _focusedDay ?? selectedDate,
              currentDay: today,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              selectedDayPredicate: (day) =>
                  _normalizeDate(day) == selectedDate,
              calendarFormat: CalendarFormat.week,
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronVisible: false,
                rightChevronVisible: false,
                headerMargin: EdgeInsets.only(
                  bottom: HomeConstants.spacingSmall,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  const weekdays = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  final weekdayStr = weekdays[day.weekday - 1];

                  return Center(
                    child: Text(
                      weekdayStr,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
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
                  final currentIndex = navigableDates.indexOf(selectedDate);
                  final indexDifference = (targetIndex - currentIndex).abs();

                  setState(() {
                    _focusedDay = focusedDay;
                  });

                  if (indexDifference > 1) {
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
                ? _buildEmptyStateLoader(context)
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
                        final isToday = date == today;
                        final entry = provider.entries
                            .where((e) => _normalizeDate(e.date) == date)
                            .firstOrNull;

                        if (entry == null && isToday) {
                          return Align(
                            alignment: const Alignment(
                              0.0,
                              HomeConstants.emptyStateAlignmentY,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  HomeConstants.emptyTodayText,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(
                                  height: HomeConstants.spacingMedium,
                                ),
                                SizedBox(
                                  height: HomeConstants.emptyStateFabHeight,
                                  width: HomeConstants.emptyStateFabHeight,
                                  child: Center(
                                    child: FloatingActionButton.large(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      onPressed: () {
                                        context.push(
                                          AppRoutes.journalEditorPath,
                                          extra: {AppRoutes.argEntryDate: date},
                                        );
                                      },
                                      child: const Icon(Icons.add),
                                    ),
                                  ),
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
                          child: JournalCard(
                            entry: entry,
                            isMuted: audioProvider.isMuted,
                            isLoading: audioProvider.isGlobalLoading,
                            hasError: audioProvider.hasGlobalError,
                            onToggleMute: () => audioProvider.toggleMute(),
                            onDelete: () => _showDeleteDialog(context, entry),
                            onEdit: () {
                              context.push(
                                AppRoutes.journalEditorPath,
                                extra: {
                                  AppRoutes.argEntryDate: date,
                                  AppRoutes.argExistingEntry: entry,
                                },
                              );
                            },
                            onExpand: () {
                              context.push(
                                AppRoutes.journalExpandedPath,
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
