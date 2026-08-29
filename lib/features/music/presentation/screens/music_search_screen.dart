import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../constants/music_constants.dart';
import '../providers/music_search_provider.dart';
import '../providers/audio_provider.dart';

class MusicSearchScreen extends StatefulWidget {
  const MusicSearchScreen({super.key});

  @override
  State<MusicSearchScreen> createState() => _MusicSearchScreenState();
}

class _MusicSearchScreenState extends State<MusicSearchScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildPlayButtonIcon(
    BuildContext context,
    bool isCurrent,
    AudioProvider audioProvider,
  ) {
    if (!isCurrent) {
      return Icon(
        Icons.play_arrow_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: MusicConstants.iconSize,
      );
    }

    if (audioProvider.isSearchLoading) {
      return SizedBox(
        width: MusicConstants.loadingSpinnerSize,
        height: MusicConstants.loadingSpinnerSize,
        child: CircularProgressIndicator(
          strokeWidth: MusicConstants.loadingSpinnerStroke,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (audioProvider.hasSearchError) {
      return Icon(
        Icons.priority_high_rounded,
        color: Theme.of(context).colorScheme.error,
        size: MusicConstants.iconSize,
      );
    }

    return Icon(
      audioProvider.isSearchPlaying
          ? Icons.pause_rounded
          : Icons.play_arrow_rounded,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      size: MusicConstants.iconSize,
    );
  }

  Widget _buildStatusView(
    BuildContext context, {
    required Widget graphic,
    required String text,
    required bool showText,
  }) {
    return Align(
      alignment: const Alignment(0.0, MusicConstants.emptyStateAlignmentY),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MusicConstants.emptyStateIconSize,
              child: Center(child: graphic),
            ),
            const SizedBox(height: MusicConstants.spacingMedium),
            Visibility(
              visible: showText,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicSearchProvider>();
    final audioProvider = context.watch<AudioProvider>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && result == null) {
          context.read<AudioProvider>().stopSearchTrackAndRestoreGlobal();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            MusicConstants.searchScreenTitle,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(
                    MusicConstants.horizontalPadding,
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: MusicConstants.searchHint,
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(
                        const Duration(
                          milliseconds: MusicConstants.searchDebounceMs,
                        ),
                        () {
                          if (mounted) {
                            context.read<AudioProvider>().clearSearchTrack();
                            context.read<MusicSearchProvider>().searchSongs(
                              value,
                            );
                          }
                        },
                      );
                    },
                    onSubmitted: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      context.read<AudioProvider>().clearSearchTrack();
                      context.read<MusicSearchProvider>().searchSongs(value);
                    },
                  ),
                ),
                Expanded(
                  child: provider.isLoading
                      ? _buildStatusView(
                          context,
                          graphic: SpinKitThreeBounce(
                            color: Theme.of(context).colorScheme.primary,
                            size: MusicConstants.iconSize,
                          ),
                          text: MusicConstants.emptySearchPrompt,
                          showText: false,
                        )
                      : provider.error != null
                      ? _buildStatusView(
                          context,
                          graphic: Icon(
                            provider.error == MusicConstants.networkError
                                ? Icons.music_off_rounded
                                : Icons.error_outline_rounded,
                            size: MusicConstants.emptyStateIconSize,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          text: provider.error!,
                          showText: true,
                        )
                      : provider.results.isEmpty
                      ? _buildStatusView(
                          context,
                          graphic: Icon(
                            Icons.music_note_rounded,
                            size: MusicConstants.emptyStateIconSize,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          text: _searchController.text.isEmpty
                              ? MusicConstants.emptySearchPrompt
                              : MusicConstants.noResultsText,
                          showText: true,
                        )
                      : ListView.builder(
                          itemCount: provider.results.length,
                          itemBuilder: (context, index) {
                            final music = provider.results[index];
                            final isCurrent =
                                audioProvider.currentSearchUrl ==
                                music.previewUrl;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: MusicConstants.horizontalPadding,
                                vertical:
                                    MusicConstants.listTileVerticalPadding,
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  MusicConstants.albumArtRadius,
                                ),
                                child: Container(
                                  width: MusicConstants.albumArtSize,
                                  height: MusicConstants.albumArtSize,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    fit: StackFit.expand,
                                    children: [
                                      Icon(
                                        Icons.music_note_rounded,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      if (music.coverUrl.isNotEmpty)
                                        Image.network(
                                          music.coverUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => const SizedBox.shrink(),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              title: Text(
                                music.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                music.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Container(
                                width: MusicConstants.listButtonSize,
                                height: MusicConstants.listButtonSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => audioProvider
                                        .toggleSearchTrack(music.previewUrl),
                                    child: Center(
                                      child: _buildPlayButtonIcon(
                                        context,
                                        isCurrent,
                                        audioProvider,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                context
                                    .read<AudioProvider>()
                                    .clearSearchTrack();
                                context.pop(music);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
