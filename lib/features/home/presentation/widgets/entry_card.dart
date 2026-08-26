import 'package:flutter/material.dart';

import '../../../../core/constants/date_constants.dart';
import '../../../../features/journal/domain/models/journal_entry.dart';
import '../../constants/home_constants.dart';

class EntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onExpand;
  final VoidCallback onEdit;
  final VoidCallback onToggleMute;
  final VoidCallback onDelete;
  final bool isMuted;

  const EntryCard({
    super.key,
    required this.entry,
    required this.onExpand,
    required this.onEdit,
    required this.onToggleMute,
    required this.onDelete,
    required this.isMuted,
  });

  String _formatDate(DateTime date) {
    return '${DateConstants.months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildCircleButton(
    BuildContext context,
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onPressed,
  ) {
    return Container(
      width: HomeConstants.entryCardCircleButtonSize,
      height: HomeConstants.entryCardCircleButtonSize,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: IconButton(
        icon: Icon(icon, size: HomeConstants.iconSizeMedium),
        color: iconColor,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleText = entry.title?.trim().isNotEmpty == true
        ? entry.title!
        : _formatDate(entry.date);

    final hasBody = entry.body.trim().isNotEmpty;
    final hasMusic =
        entry.songTitle != null ||
        entry.songCoverUrl != null ||
        entry.songPreviewUrl != null;

    final now = DateTime.now();
    final isEditable =
        entry.date.year == now.year &&
        entry.date.month == now.month &&
        entry.date.day == now.day;

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
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(
                      HomeConstants.entryCardMusicCoverRadius,
                    ),
                  ),
                  child: entry.songCoverUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            HomeConstants.entryCardMusicCoverRadius,
                          ),
                          child: Image.network(
                            entry.songCoverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.music_note,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.music_note,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                ),
                const SizedBox(width: HomeConstants.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.songTitle ?? HomeConstants.unknownSongText,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: HomeConstants.singleLine,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (entry.songArtist != null)
                        Text(
                          entry.songArtist!,
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
                if (entry.songPreviewUrl != null) ...[
                  const SizedBox(width: HomeConstants.spacingTiny),
                  IconButton(
                    icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: onToggleMute,
                  ),
                ],
              ],
            ),
            const SizedBox(height: HomeConstants.spacingExtraLarge),
          ],

          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    titleText,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                      entry.body,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

          const SizedBox(height: HomeConstants.spacingExtraLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isEditable) ...[
                _buildCircleButton(
                  context,
                  Icons.delete_outline_rounded,
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                  Theme.of(context).colorScheme.error,
                  onDelete,
                ),
                const SizedBox(width: HomeConstants.spacingExtraLarge),
              ],
              _buildCircleButton(
                context,
                Icons.fullscreen_rounded,
                Theme.of(context).colorScheme.surfaceContainerHighest,
                Theme.of(context).colorScheme.onSurfaceVariant,
                onExpand,
              ),
              if (isEditable) ...[
                const SizedBox(width: HomeConstants.spacingExtraLarge),
                _buildCircleButton(
                  context,
                  Icons.edit_rounded,
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                  Theme.of(context).colorScheme.onSurfaceVariant,
                  onEdit,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
