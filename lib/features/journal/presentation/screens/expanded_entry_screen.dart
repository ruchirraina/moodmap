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
    required IconData icon,
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
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: ComposerConstants.iconSizeMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildPillButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: ComposerConstants.circleButtonSize,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(
          ComposerConstants.circleButtonSize / 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            ComposerConstants.circleButtonSize / 2,
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: ComposerConstants.iconSizeMedium,
                ),
                const SizedBox(width: 8.0),
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              icon: Icons.arrow_back_rounded,
              onTap: () => context.pop(),
            ),
          ),
        ),
        actions: [
          Center(
            child: _buildPillButton(
              context,
              icon: Icons.add_rounded,
              label: 'Music',
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
                icon: Icons.edit_rounded,
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
