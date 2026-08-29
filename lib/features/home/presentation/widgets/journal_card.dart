import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_animations.dart';
import '../../../../core/constants/date_constants.dart';
import '../../../../core/utils/loading_utils.dart';
import '../../../../features/journal/domain/models/journal_entry.dart';
import '../../../../features/journal/presentation/providers/journal_provider.dart';
import '../../constants/home_constants.dart';

class JournalCard extends StatefulWidget {
  final JournalEntry entry;
  final VoidCallback onExpand;
  final VoidCallback onToggleMute;
  final VoidCallback onDelete;
  final bool isMuted;
  final bool isLoading;
  final bool hasError;

  const JournalCard({
    super.key,
    required this.entry,
    required this.onExpand,
    required this.onToggleMute,
    required this.onDelete,
    required this.isMuted,
    required this.isLoading,
    required this.hasError,
  });

  @override
  State<JournalCard> createState() => _JournalCardState();
}

class _JournalCardState extends State<JournalCard>
    with SingleTickerProviderStateMixin {
  bool _isAiMode = false;
  bool _isAiLoading = false;
  bool _hasAiError = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: HomeConstants.pulseAnimationDurationMs,
      ),
    )..repeat(reverse: true);

    _pulseAnimation =
        Tween<double>(
          begin: HomeConstants.pulseScaleBegin,
          end: HomeConstants.pulseScaleEnd,
        ).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${DateConstants.months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> _generateAiMoodMap() async {
    setState(() {
      _isAiLoading = true;
      _hasAiError = false;
    });

    final startTime = DateTime.now();

    final success = await context.read<JournalProvider>().generateAiMoodMap(
      widget.entry,
    );

    if (!mounted) return;

    await LoadingUtils.enforceMinimumLoadTime(startTime);

    if (!mounted) return;

    setState(() {
      _isAiLoading = false;
      _hasAiError = !success;
    });
  }

  Future<void> _toggleAiMode() async {
    if (_isAiMode) {
      setState(() {
        _isAiMode = false;
      });
      return;
    }

    setState(() {
      _isAiMode = true;
      _hasAiError = false;
    });

    if (widget.entry.aiSummary != null && widget.entry.aiColors != null) {
      return;
    }

    await _generateAiMoodMap();
  }

  Widget _buildCircleButton(
    BuildContext context,
    Widget iconWidget,
    Color bgColor,
    Color iconColor,
    VoidCallback onPressed, {
    double size = HomeConstants.entryCardCircleButtonSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: IconButton(
        icon: iconWidget,
        color: iconColor,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPlayButtonIcon(BuildContext context) {
    if (widget.isLoading) {
      return SizedBox(
        width: HomeConstants.loaderSize,
        height: HomeConstants.loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: HomeConstants.loaderStrokeWidth,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    if (widget.hasError) {
      return Icon(
        Icons.priority_high_rounded,
        color: Theme.of(context).colorScheme.error,
        size: HomeConstants.iconSizeMedium,
      );
    }
    return Icon(
      widget.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      size: HomeConstants.iconSizeMedium,
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.entry.title?.trim().isNotEmpty == true
        ? widget.entry.title!
        : _formatDate(widget.entry.date);

    final hasBody = widget.entry.body.trim().isNotEmpty;
    final hasMusic =
        widget.entry.songTitle != null ||
        widget.entry.songCoverUrl != null ||
        widget.entry.songPreviewUrl != null;

    final now = DateTime.now();
    final isEditable =
        widget.entry.date.year == now.year &&
        widget.entry.date.month == now.month &&
        widget.entry.date.day == now.day;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: HomeConstants.horizontalPadding,
        vertical: HomeConstants.spacingMedium,
      ),
      padding: const EdgeInsets.all(HomeConstants.entryCardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(HomeConstants.entryCardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasMusic) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: HomeConstants.entryCardMusicCoverSize,
                  height: HomeConstants.entryCardMusicCoverSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      HomeConstants.entryCardMusicCoverRadius,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      Icon(
                        Icons.music_note_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      if (widget.entry.songCoverUrl != null &&
                          widget.entry.songCoverUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            HomeConstants.entryCardMusicCoverRadius,
                          ),
                          child: Image.network(
                            widget.entry.songCoverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: HomeConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.entry.songTitle ?? HomeConstants.unknownSongText,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: HomeConstants.singleLine,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.entry.songArtist != null)
                        Text(
                          widget.entry.songArtist!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                          maxLines: HomeConstants.singleLine,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (widget.entry.songPreviewUrl != null) ...[
                  const SizedBox(width: HomeConstants.spacingTiny),
                  _buildCircleButton(
                    context,
                    _buildPlayButtonIcon(context),
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                    widget.onToggleMute,
                  ),
                ],
              ],
            ),
            const SizedBox(height: HomeConstants.spacingExtraLarge),
          ],
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _isAiMode ? 0.0 : 1.0,
                  duration: AppAnimations.animatedSizeDuration,
                  child: IgnorePointer(
                    ignoring: _isAiMode,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            titleText,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: HomeConstants.titleMaxLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (hasBody) ...[
                            const SizedBox(height: HomeConstants.spacingSmall),
                            Text(
                              widget.entry.body,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    height: HomeConstants.bodyLineHeight,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: HomeConstants.bodyMaxLines,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _isAiMode ? 1.0 : 0.0,
                  duration: AppAnimations.animatedSizeDuration,
                  child: IgnorePointer(
                    ignoring: !_isAiMode,
                    child: AnimatedSwitcher(
                      duration: AppAnimations.animatedSizeDuration,
                      child: _isAiLoading
                          ? SpinKitThreeBounce(
                              key: const ValueKey('ai_loading'),
                              color: Theme.of(context).colorScheme.primary,
                              size: HomeConstants.iconSizeMedium,
                            )
                          : _hasAiError
                          ? Column(
                              key: const ValueKey('ai_error'),
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildCircleButton(
                                  context,
                                  const Icon(
                                    Icons.refresh_rounded,
                                    size: HomeConstants.iconSizeMedium,
                                  ),
                                  Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  _generateAiMoodMap,
                                ),
                                const SizedBox(
                                  height: HomeConstants.spacingMedium,
                                ),
                                Text(
                                  HomeConstants.aiConnectionError,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            )
                          : (widget.entry.aiSummary != null &&
                                widget.entry.aiColors != null)
                          ? Stack(
                              key: const ValueKey('ai_result'),
                              fit: StackFit.expand,
                              children: [
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        HomeConstants.entryCardRadius,
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors:
                                            widget.entry.aiColors!.length >=
                                                HomeConstants.minGradientColors
                                            ? widget.entry.aiColors!
                                                  .map(_fromHex)
                                                  .toList()
                                            : [
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                Theme.of(context)
                                                    .colorScheme
                                                    .tertiary,
                                              ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(
                                    HomeConstants.entryCardPadding,
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.entry.aiSummary!,
                                      textAlign: TextAlign.center,
                                      maxLines: HomeConstants.aiSummaryMaxLines,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            height:
                                                HomeConstants.bodyLineHeight,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withValues(
                                                  alpha:
                                                      HomeConstants.shadowAlpha,
                                                ),
                                                blurRadius: HomeConstants
                                                    .shadowBlurRadius,
                                                offset: const Offset(
                                                  0,
                                                  HomeConstants.shadowOffsetY,
                                                ),
                                              ),
                                            ],
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(key: ValueKey('ai_empty')),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: HomeConstants.spacingExtraLarge),
          Row(
            children: [
              if (isEditable)
                AnimatedOpacity(
                  opacity: _isAiMode ? 0.0 : 1.0,
                  duration: AppAnimations.animatedSizeDuration,
                  child: IgnorePointer(
                    ignoring: _isAiMode,
                    child: _buildCircleButton(
                      context,
                      Icon(
                        Icons.delete_outline_rounded,
                        size: HomeConstants.iconSizeMedium,
                      ),
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                      Theme.of(context).colorScheme.error,
                      widget.onDelete,
                    ),
                  ),
                )
              else
                const SizedBox(width: HomeConstants.entryCardCircleButtonSize),

              const Spacer(),

              _buildCircleButton(
                context,
                AnimatedSwitcher(
                  duration: AppAnimations.animatedSizeDuration,
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    _isAiMode
                        ? Icons.close_rounded
                        : Icons.auto_awesome_rounded,
                    key: ValueKey(_isAiMode),
                    size: HomeConstants.iconSizeMedium,
                  ),
                ),
                Theme.of(context).colorScheme.surfaceContainerHighest,
                Theme.of(context).colorScheme.onSurfaceVariant,
                _toggleAiMode,
              ),

              const Spacer(),

              AnimatedOpacity(
                opacity: _isAiMode ? 0.0 : 1.0,
                duration: AppAnimations.animatedSizeDuration,
                child: IgnorePointer(
                  ignoring: _isAiMode,
                  child: _buildCircleButton(
                    context,
                    Icon(
                      Icons.fullscreen_rounded,
                      size: HomeConstants.iconSizeMedium,
                    ),
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                    Theme.of(context).colorScheme.onSurfaceVariant,
                    widget.onExpand,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
