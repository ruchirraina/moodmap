import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/date_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../domain/models/journal_entry.dart';
import '../providers/journal_editor_provider.dart';
import '../../constants/journal_editor_constants.dart';

class JournalEditorScreen extends StatefulWidget {
  final DateTime entryDate;
  final JournalEntry? existingEntry;

  const JournalEditorScreen({
    super.key,
    required this.entryDate,
    this.existingEntry,
  });

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
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
      context.read<JournalEditorProvider>().updateCharacterCount(
        _bodyController.text.length,
      );
      if (_titleController.text.isNotEmpty) {
        context.read<JournalEditorProvider>().onTitleChanged(
          _titleController.text,
        );
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
    final provider = context.watch<JournalEditorProvider>();

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
            child: SizedBox(
              width: JournalEditorConstants.circleButtonSize,
              height: JournalEditorConstants.circleButtonSize,
              child: IconButton.outlined(
                icon: const Icon(Icons.close_rounded),
                iconSize: JournalEditorConstants.iconSizeMedium,
                style: IconButton.styleFrom(
                  side: BorderSide(
                    color: provider.isLoading
                        ? Theme.of(context).colorScheme.tertiary.withValues(
                            alpha: JournalEditorConstants.disabledBorderAlpha,
                          )
                        : Theme.of(context).colorScheme.tertiary,
                    width: JournalEditorConstants.buttonBorderWidth,
                  ),
                  foregroundColor: provider.isLoading
                      ? Theme.of(context).colorScheme.tertiary.withValues(
                          alpha: JournalEditorConstants.disabledTextAlpha,
                        )
                      : Theme.of(context).colorScheme.tertiary,
                ),
                onPressed: provider.isLoading ? null : () => context.pop(),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: JournalEditorConstants.horizontalPadding,
            ),
            child: Center(
              child: SizedBox(
                width: JournalEditorConstants.circleButtonSize,
                height: JournalEditorConstants.circleButtonSize,
                child: IconButton.filled(
                  icon: provider.isLoading
                      ? SpinKitThreeBounce(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(
                                alpha: JournalEditorConstants.disabledTextAlpha,
                              ),
                          size: JournalEditorConstants.loaderSize,
                        )
                      : const Icon(Icons.check_rounded),
                  iconSize: JournalEditorConstants.iconSizeMedium,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  onPressed:
                      (provider.isLoading || provider.hasValidationErrors)
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          final savedEntry = await context
                              .read<JournalEditorProvider>()
                              .saveEntry(
                                sessionStart: _sessionStart,
                                entryDate: widget.entryDate,
                                title: _titleController.text,
                                body: _bodyController.text,
                                existingEntry: widget.existingEntry,
                              );

                          if (context.mounted) {
                            if (savedEntry != null) {
                              AppRouter.navigateWithFade(
                                context,
                                AppRoutes.journalExpandedPath,
                                extra: {
                                  AppRoutes.argExistingEntry: savedEntry,
                                  AppRoutes.argIsFadeTransition: true,
                                },
                              );
                            } else if (provider.error == null) {
                              context.pop();
                            }
                          }
                        },
                ),
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
                milliseconds: JournalEditorConstants.animationDurationMs,
              ),
              child: provider.error != null
                  ? Container(
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.errorContainer,
                      padding: const EdgeInsets.all(
                        JournalEditorConstants.errorPadding,
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
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
                                  .withValues(
                                    alpha: JournalEditorConstants.alphaHalf,
                                  ),
                              fontWeight: FontWeight.bold,
                            ),
                        border: InputBorder.none,
                      ),
                      onChanged: (text) {
                        context.read<JournalEditorProvider>().onTitleChanged(
                          text,
                        );
                      },
                    ),
                    AnimatedSize(
                      duration: const Duration(
                        milliseconds:
                            JournalEditorConstants.animationDurationMs,
                      ),
                      child: provider.titleError != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                top: JournalEditorConstants.errorTopPadding,
                              ),
                              child: Text(
                                provider.titleError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize:
                                      JournalEditorConstants.errorFontSize,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.outlineVariant
                          .withValues(alpha: JournalEditorConstants.alphaHalf),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _bodyController,
                        maxLines: null,
                        expands: true,
                        maxLength: JournalEditorConstants.bodyCharacterLimit,
                        maxLengthEnforcement: MaxLengthEnforcement.none,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: JournalEditorConstants.bodyHint,
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        onChanged: (text) {
                          context
                              .read<JournalEditorProvider>()
                              .updateCharacterCount(text.length);
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${provider.currentLength} / ${JournalEditorConstants.bodyCharacterLimit}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              provider.currentLength >
                                  JournalEditorConstants.bodyCharacterLimit
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.onSurfaceVariant,
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
