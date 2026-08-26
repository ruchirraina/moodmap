import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/date_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/models/journal_entry.dart';
import '../../constants/composer_constants.dart';

class ExpandedEntryScreen extends StatefulWidget {
  final JournalEntry entry;

  const ExpandedEntryScreen({super.key, required this.entry});

  @override
  State<ExpandedEntryScreen> createState() => _ExpandedEntryScreenState();
}

class _ExpandedEntryScreenState extends State<ExpandedEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    final titleText = widget.entry.title?.trim().isNotEmpty == true
        ? widget.entry.title!
        : _formatDate(widget.entry.date);

    _titleController = TextEditingController(text: titleText);
    _bodyController = TextEditingController(text: widget.entry.body);
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

  Widget _buildCircleButton(
    BuildContext context, {
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return Container(
      width: ComposerConstants.circleButtonSize,
      height: ComposerConstants.circleButtonSize,
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isEditable =
        widget.entry.date.year == now.year &&
        widget.entry.date.month == now.month &&
        widget.entry.date.day == now.day;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: ComposerConstants.appBarLeadingWidth,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: ComposerConstants.horizontalPadding,
          ),
          child: Center(
            child: _buildCircleButton(
              context,
              iconWidget: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: ComposerConstants.iconSizeMedium,
              ),
              onTap: () => context.pop(),
            ),
          ),
        ),
        actions: [
          if (isEditable) ...[
            Center(
              child: _buildCircleButton(
                context,
                iconWidget: SizedBox(
                  width: 30.0,
                  height: 26.0,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Icon(
                          Icons.music_note_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 24.0,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: SizedBox(
                          width: 10.0,
                          height: 10.0,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 10.0,
                                height: 2.5,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  borderRadius: BorderRadius.circular(1.0),
                                ),
                              ),
                              Container(
                                width: 2.5,
                                height: 10.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  borderRadius: BorderRadius.circular(1.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12.0),
            Padding(
              padding: const EdgeInsets.only(
                right: ComposerConstants.horizontalPadding,
              ),
              child: Center(
                child: _buildCircleButton(
                  context,
                  iconWidget: Icon(
                    Icons.edit_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: ComposerConstants.iconSizeMedium,
                  ),
                  onTap: () {
                    AppRouter.navigateWithFade(
                      context,
                      AppRoutes.composerPath,
                      extra: {
                        AppRoutes.argEntryDate: widget.entry.date,
                        AppRoutes.argExistingEntry: widget.entry,
                        AppRoutes.argIsFadeTransition: true,
                      },
                    );
                  },
                ),
              ),
            ),
          ] else
            const SizedBox(width: ComposerConstants.horizontalPadding),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(
                  ComposerConstants.horizontalPadding,
                ),
                padding: const EdgeInsets.all(ComposerConstants.cardPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(
                    ComposerConstants.cardRadius,
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
                          .withValues(alpha: ComposerConstants.alphaHalf),
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
                          '0 / ${ComposerConstants.bodyCharacterLimit}',
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
