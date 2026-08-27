import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/date_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/models/journal_entry.dart';
import '../../constants/journal_editor_constants.dart';
import '../providers/journal_provider.dart';
import '../../../music/domain/models/music_result.dart';
import '../../../music/presentation/providers/audio_provider.dart';

class JournalExpandedScreen extends StatefulWidget {
  final JournalEntry entry;

  const JournalExpandedScreen({super.key, required this.entry});

  @override
  State<JournalExpandedScreen> createState() => _JournalExpandedScreenState();
}

class _JournalExpandedScreenState extends State<JournalExpandedScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late JournalEntry _currentEntry;

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;

    final titleText = _currentEntry.title?.trim().isNotEmpty == true
        ? _currentEntry.title!
        : _formatDate(_currentEntry.date);

    _titleController = TextEditingController(text: titleText);
    _bodyController = TextEditingController(text: _currentEntry.body);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${DateConstants.months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _updateEntryMusic(MusicResult? music) {
    final updatedEntry = JournalEntry(
      id: _currentEntry.id,
      userId: _currentEntry.userId,
      date: _currentEntry.date,
      title: _currentEntry.title,
      body: _currentEntry.body,
      songTitle: music?.title,
      songArtist: music?.artist,
      songCoverUrl: music?.coverUrl,
      songPreviewUrl: music?.previewUrl,
      aiSummary: _currentEntry.aiSummary,
      aiColors: _currentEntry.aiColors,
      createdAt: _currentEntry.createdAt,
      updatedAt: DateTime.now(),
    );

    setState(() {
      _currentEntry = updatedEntry;
    });

    context.read<AudioProvider>().setGlobalTrack(music?.previewUrl);
    context.read<JournalProvider>().saveEntry(updatedEntry);
  }

  Widget _buildCircleButton(
    BuildContext context, {
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return Container(
      width: JournalEditorConstants.circleButtonSize,
      height: JournalEditorConstants.circleButtonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(child: iconWidget),
        ),
      ),
    );
  }

  Widget _buildPlayButtonIcon(
    BuildContext context,
    AudioProvider audioProvider,
  ) {
    if (audioProvider.isGlobalLoading) {
      return SizedBox(
        width: JournalEditorConstants.loaderSize,
        height: JournalEditorConstants.loaderSize,
        child: CircularProgressIndicator(
          strokeWidth: JournalEditorConstants.loaderStrokeWidth,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    if (audioProvider.hasGlobalError) {
      return Icon(
        Icons.priority_high_rounded,
        color: Theme.of(context).colorScheme.error,
        size: JournalEditorConstants.iconSizeMedium,
      );
    }
    return Icon(
      audioProvider.isMuted
          ? Icons.volume_off_rounded
          : Icons.volume_up_rounded,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      size: JournalEditorConstants.iconSizeMedium,
    );
  }

  Widget _buildMusicPill(
    BuildContext context,
    bool hasMusic,
    bool isEditable,
    AudioProvider audioProvider,
  ) {
    if (!hasMusic && !isEditable) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(
        JournalEditorConstants.circleButtonSize / 2,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          JournalEditorConstants.circleButtonSize / 2,
        ),
        onTap: (!hasMusic && isEditable)
            ? () async {
                final result = await context.push<MusicResult>(
                  AppRoutes.musicSearchPath,
                );
                if (result != null && mounted) {
                  _updateEntryMusic(result);
                }
              }
            : null,
        child: Container(
          height: JournalEditorConstants.circleButtonSize,
          padding: const EdgeInsets.symmetric(
            horizontal: JournalEditorConstants.spacingMedium,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasMusic) ...[
                if (_currentEntry.songCoverUrl != null &&
                    _currentEntry.songCoverUrl!.isNotEmpty) ...[
                  ClipOval(
                    child: Image.network(
                      _currentEntry.songCoverUrl!,
                      width: JournalEditorConstants.musicPillCoverSize,
                      height: JournalEditorConstants.musicPillCoverSize,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: JournalEditorConstants.musicPillCoverSize,
                          height: JournalEditorConstants.musicPillCoverSize,
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer,
                          child: Icon(
                            Icons.music_note_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                            size: JournalEditorConstants.iconSizeSmall,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: JournalEditorConstants.musicPillCoverSize,
                        height: JournalEditorConstants.musicPillCoverSize,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Icon(
                          Icons.music_note_rounded,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          size: JournalEditorConstants.iconSizeSmall,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: JournalEditorConstants.spacingSmall),
                ],
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => audioProvider.toggleMute(),
                    child: Container(
                      width: JournalEditorConstants.musicPillCoverSize,
                      height: JournalEditorConstants.musicPillCoverSize,
                      alignment: Alignment.center,
                      child: _buildPlayButtonIcon(context, audioProvider),
                    ),
                  ),
                ),
                if (isEditable) ...[
                  const SizedBox(width: JournalEditorConstants.spacingSmall),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _updateEntryMusic(null),
                      child: Container(
                        width: JournalEditorConstants.musicPillCoverSize,
                        height: JournalEditorConstants.musicPillCoverSize,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close_rounded,
                          color: Theme.of(context).colorScheme.error,
                          size: JournalEditorConstants.iconSizeMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ] else if (isEditable) ...[
                Icon(
                  Icons.music_note_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: JournalEditorConstants.iconSizeMedium,
                ),
                const SizedBox(width: JournalEditorConstants.spacingSmall),
                Icon(
                  Icons.add_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: JournalEditorConstants.iconSizeMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final now = DateTime.now();
    final isEditable =
        _currentEntry.date.year == now.year &&
        _currentEntry.date.month == now.month &&
        _currentEntry.date.day == now.day;

    final hasMusic =
        _currentEntry.songCoverUrl != null ||
        _currentEntry.songPreviewUrl != null ||
        _currentEntry.songTitle != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: JournalEditorConstants.appBarLeadingWidth,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: JournalEditorConstants.horizontalPadding,
          ),
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: JournalEditorConstants.iconSizeMedium,
              ),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: _buildMusicPill(context, hasMusic, isEditable, audioProvider),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: JournalEditorConstants.horizontalPadding,
            ),
            child: Center(
              child: isEditable
                  ? _buildCircleButton(
                      context,
                      iconWidget: Icon(
                        Icons.edit_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: JournalEditorConstants.iconSizeMedium,
                      ),
                      onTap: () {
                        AppRouter.navigateWithFade(
                          context,
                          AppRoutes.journalEditorPath,
                          extra: {
                            AppRoutes.argEntryDate: _currentEntry.date,
                            AppRoutes.argExistingEntry: _currentEntry,
                            AppRoutes.argIsFadeTransition: true,
                          },
                        );
                      },
                    )
                  : const SizedBox(
                      width: JournalEditorConstants.circleButtonSize,
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(
                  JournalEditorConstants.horizontalPadding,
                ),
                padding: const EdgeInsets.all(
                  JournalEditorConstants.cardPadding,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(
                    JournalEditorConstants.cardRadius,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _titleController,
                      readOnly: true,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.outlineVariant
                          .withValues(alpha: JournalEditorConstants.alphaHalf),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _bodyController,
                        readOnly: true,
                        maxLines: null,
                        expands: true,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.0,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '0 / ${JournalEditorConstants.bodyCharacterLimit}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
