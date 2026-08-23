import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/constants/date_constants.dart';
import '../../domain/models/journal_entry.dart';
import '../providers/composer_provider.dart';
import '../../constants/composer_constants.dart';

class ComposerScreen extends StatefulWidget {
  final DateTime entryDate;
  final JournalEntry? existingEntry;

  const ComposerScreen({
    super.key,
    required this.entryDate,
    this.existingEntry,
  });

  @override
  State<ComposerScreen> createState() => _ComposerScreenState();
}

class _ComposerScreenState extends State<ComposerScreen> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late DateTime _sessionStart;
  late String _fallbackTitle;

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();

    _fallbackTitle =
        '${DateConstants.months[widget.entryDate.month - 1]} ${widget.entryDate.day}, ${widget.entryDate.year}';

    _titleController = TextEditingController(text: widget.existingEntry?.title);
    _bodyController = TextEditingController(text: widget.existingEntry?.body);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComposerProvider>().updateCharacterCount(
        _bodyController.text.length,
      );
      if (_titleController.text.isNotEmpty) {
        context.read<ComposerProvider>().onTitleChanged(_titleController.text);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComposerProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: ComposerConstants.appBarLeadingWidth,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: ComposerConstants.horizontalPadding,
            top: ComposerConstants.appBarButtonVertical,
            bottom: ComposerConstants.appBarButtonVertical,
          ),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.tertiary),
              foregroundColor: Theme.of(context).colorScheme.tertiary,
              padding: EdgeInsets.zero,
            ),
            onPressed: provider.isLoading ? null : () => context.pop(),
            child: const Text(
              ComposerConstants.cancelText,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: ComposerConstants.horizontalPadding,
              top: ComposerConstants.appBarButtonVertical,
              bottom: ComposerConstants.appBarButtonVertical,
            ),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              onPressed: (provider.isLoading || provider.hasValidationErrors)
                  ? null
                  : () async {
                      FocusScope.of(context).unfocus();
                      final success = await context
                          .read<ComposerProvider>()
                          .saveEntry(
                            sessionStart: _sessionStart,
                            entryDate: widget.entryDate,
                            title: _titleController.text,
                            body: _bodyController.text,
                            existingEntry: widget.existingEntry,
                          );
                      if (success && context.mounted) {
                        context.pop();
                      }
                    },
              child: provider.isLoading
                  ? SpinKitThreeBounce(
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: ComposerConstants.disabledTextAlpha,
                      ),
                      size: ComposerConstants.loaderSize,
                    )
                  : const Text(
                      ComposerConstants.doneText,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            AnimatedSize(
              duration: const Duration(
                milliseconds: ComposerConstants.animationDurationMs,
              ),
              child: provider.error != null
                  ? Container(
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.errorContainer,
                      padding: const EdgeInsets.all(
                        ComposerConstants.errorPadding,
                      ),
                      child: Text(
                        provider.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ComposerConstants.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    decoration: InputDecoration(
                      hintText: _fallbackTitle,
                      hintStyle: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: ComposerConstants.alphaHalf),
                            fontWeight: FontWeight.bold,
                          ),
                      border: InputBorder.none,
                    ),
                    onChanged: (text) {
                      context.read<ComposerProvider>().onTitleChanged(text);
                    },
                  ),
                  AnimatedSize(
                    duration: const Duration(
                      milliseconds: ComposerConstants.animationDurationMs,
                    ),
                    child: provider.titleError != null
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: ComposerConstants.errorTopPadding,
                            ),
                            child: Text(
                              provider.titleError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: ComposerConstants.errorFontSize,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ComposerConstants.horizontalPadding,
              ),
              child: Divider(
                color: Theme.of(context).colorScheme.outlineVariant
                    .withValues(alpha: ComposerConstants.alphaHalf),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ComposerConstants.horizontalPadding,
                ),
                child: TextField(
                  controller: _bodyController,
                  maxLines: null,
                  expands: true,
                  maxLength: ComposerConstants.bodyCharacterLimit,
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: ComposerConstants.bodyHint,
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (text) {
                    context.read<ComposerProvider>().updateCharacterCount(
                      text.length,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                ComposerConstants.horizontalPadding,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${provider.currentLength} / ${ComposerConstants.bodyCharacterLimit}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        provider.currentLength >
                            ComposerConstants.bodyCharacterLimit
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
