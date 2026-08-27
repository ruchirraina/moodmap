import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/constants/app_animations.dart';
import '../../../../core/widgets/shake_widget.dart';
import '../../../music/presentation/providers/audio_provider.dart';
import '../../constants/profile_constants.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: ProfileConstants.spacingSmall),
              Center(
                child: CircleAvatar(
                  radius: ProfileConstants.avatarRadiusLarge,
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
                            size: ProfileConstants.fallbackIconSize,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                        ),
                        if (provider.photoURL != null &&
                            provider.photoURL!.isNotEmpty)
                          Image.network(
                            provider.photoURL!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: ProfileConstants.spacingMedium),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.currentName ?? '',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: ProfileConstants.spacingTiny),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      onPressed: () {
                        provider.reset();
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Colors.black.withValues(
                            alpha: ProfileConstants.overlayAlpha,
                          ),
                          builder: (_) => _EditNameDialog(provider: provider),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (provider.email != null)
                Center(
                  child: Text(
                    provider.email!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: ProfileConstants.spacingLarge),

              AnimatedSize(
                duration: AppAnimations.animatedSizeDuration,
                curve: Curves.easeInOut,
                child: provider.error != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ProfileConstants.horizontalPadding,
                          vertical: ProfileConstants.spacingSmall,
                        ),
                        child: Dismissible(
                          key: Key(provider.error!),
                          onDismissed: (_) => provider.clearError(),
                          child: Container(
                            padding: const EdgeInsets.all(
                              ProfileConstants.spacingSmall,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .errorContainer,
                              borderRadius: BorderRadius.circular(
                                ProfileConstants.borderRadius,
                              ),
                            ),
                            child: Text(
                              provider.error!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ProfileConstants.horizontalPadding,
                ),
                child: Text(
                  ProfileConstants.themeSectionTitle,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: ProfileConstants.spacingSmall),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ProfileConstants.horizontalPadding,
                ),
                child: _ThemeSelector(
                  currentMode: themeProvider.themeMode,
                  onModeChanged: (mode) => themeProvider.setThemeMode(mode),
                ),
              ),
              const SizedBox(height: ProfileConstants.spacingLarge),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ProfileConstants.horizontalPadding,
                ),
                child: Text(
                  ProfileConstants.accountSectionTitle,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: ProfileConstants.spacingSmall),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: ProfileConstants.horizontalPadding,
                ),
                leading: const Icon(Icons.logout),
                title: const Text(ProfileConstants.signOutText),
                onTap: () async {
                  context.read<AudioProvider>().stopAll();
                  await provider.signOut();
                  if (context.mounted) {
                    AppRouter.navigateSequentially(
                      context,
                      AppRoutes.signInPath,
                    );
                  }
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: ProfileConstants.horizontalPadding,
                ),
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  ProfileConstants.deleteAccountText,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  provider.reset();
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: Colors.black.withValues(
                      alpha: ProfileConstants.overlayAlpha,
                    ),
                    builder: (_) => _DeleteAccountDialog(provider: provider),
                  );
                },
              ),
              const SizedBox(height: ProfileConstants.spacingLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onModeChanged;

  const _ThemeSelector({
    required this.currentMode,
    required this.onModeChanged,
  });

  Widget _buildOption(
    BuildContext context,
    ThemeMode mode,
    String label,
    IconData icon,
  ) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppAnimations.animatedSizeDuration,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: ProfileConstants.spacingSmall,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.secondaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(ProfileConstants.borderRadius),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: ProfileConstants.spacingTiny),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ProfileConstants.spacingTiny),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(ProfileConstants.borderRadius),
      ),
      child: Row(
        children: [
          _buildOption(
            context,
            ThemeMode.system,
            ProfileConstants.systemDefaultText,
            Icons.brightness_auto,
          ),
          _buildOption(
            context,
            ThemeMode.light,
            ProfileConstants.lightModeText,
            Icons.light_mode,
          ),
          _buildOption(
            context,
            ThemeMode.dark,
            ProfileConstants.darkModeText,
            Icons.dark_mode,
          ),
        ],
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final ProfileProvider provider;
  const _EditNameDialog({required this.provider});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.provider.currentName);
    _focusNode.addListener(() {
      if (mounted) {
        widget.provider.onNameFocusChanged(
          _focusNode.hasFocus,
          _controller.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String label,
    String? errorText,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(ProfileConstants.borderRadius),
      borderSide: BorderSide.none,
    );
    final activeBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(ProfileConstants.borderRadius),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.primary,
        width: ProfileConstants.borderWidth,
      ),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(ProfileConstants.borderRadius),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: ProfileConstants.borderWidth,
      ),
    );

    return InputDecoration(
      labelText: label,
      errorText: errorText,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ProfileConstants.horizontalPadding,
        vertical: ProfileConstants.inputVerticalPadding,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: activeBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: ProfileConstants.dialogBlurSigma,
        sigmaY: ProfileConstants.dialogBlurSigma,
      ),
      child: ChangeNotifierProvider.value(
        value: widget.provider,
        child: Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            return Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ProfileConstants.borderRadius,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(ProfileConstants.spacingMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ProfileConstants.editNameTitle,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ProfileConstants.spacingLarge),
                    ShakeWidget(
                      shouldShake: provider.nameError != null,
                      child: TextFormField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        enabled: !provider.isLoading,
                        decoration: _buildInputDecoration(
                          context,
                          label: ProfileConstants.nameLabel,
                          errorText: provider.nameError,
                        ),
                        onChanged: (value) {
                          provider.onNameChanged(value);
                        },
                      ),
                    ),
                    const SizedBox(height: ProfileConstants.spacingLarge),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: ProfileConstants.buttonHeight,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: provider.isLoading
                                      ? Theme.of(context).colorScheme.tertiary
                                            .withValues(
                                              alpha: ProfileConstants
                                                  .disabledBorderAlpha,
                                            )
                                      : Theme.of(context).colorScheme.tertiary,
                                ),
                                foregroundColor: provider.isLoading
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.tertiary.withValues(
                                        alpha:
                                            ProfileConstants.disabledTextAlpha,
                                      )
                                    : Theme.of(context).colorScheme.tertiary,
                              ),
                              onPressed: provider.isLoading
                                  ? null
                                  : () {
                                      provider.clearNameError();
                                      Navigator.pop(context);
                                    },
                              child: const Text(
                                ProfileConstants.cancelText,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: ProfileConstants.spacingSmall),
                        Expanded(
                          child: SizedBox(
                            height: ProfileConstants.buttonHeight,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondary,
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSecondary,
                              ),
                              onPressed: provider.isLoading
                                  ? null
                                  : () async {
                                      _focusNode.unfocus();
                                      if (provider.validateForm(
                                        _controller.text,
                                      )) {
                                        final success = await provider
                                            .updateName(_controller.text);
                                        if (success && context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
                              child: provider.isLoading
                                  ? SpinKitThreeBounce(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(
                                            alpha: ProfileConstants
                                                .disabledTextAlpha,
                                          ),
                                      size: ProfileConstants.loaderSize,
                                    )
                                  : const Text(
                                      ProfileConstants.saveText,
                                      style: TextStyle(
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
      ),
    );
  }
}

class _DeleteAccountDialog extends StatelessWidget {
  final ProfileProvider provider;

  const _DeleteAccountDialog({required this.provider});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: ProfileConstants.dialogBlurSigma,
        sigmaY: ProfileConstants.dialogBlurSigma,
      ),
      child: ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<ProfileProvider>(
          builder: (context, currentProvider, _) {
            return Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ProfileConstants.borderRadius,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(ProfileConstants.spacingMedium),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ProfileConstants.deleteAccountWarningTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ProfileConstants.spacingMedium),
                    Text(
                      ProfileConstants.deleteAccountWarningBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ProfileConstants.spacingLarge),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: ProfileConstants.buttonHeight,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: currentProvider.isLoading
                                      ? Theme.of(context).colorScheme.tertiary
                                            .withValues(
                                              alpha: ProfileConstants
                                                  .disabledBorderAlpha,
                                            )
                                      : Theme.of(context).colorScheme.tertiary,
                                ),
                                foregroundColor: currentProvider.isLoading
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.tertiary.withValues(
                                        alpha:
                                            ProfileConstants.disabledTextAlpha,
                                      )
                                    : Theme.of(context).colorScheme.tertiary,
                              ),
                              onPressed: currentProvider.isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text(
                                ProfileConstants.cancelText,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: ProfileConstants.spacingSmall),
                        Expanded(
                          child: SizedBox(
                            height: ProfileConstants.buttonHeight,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .error,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: currentProvider.isLoading
                                  ? null
                                  : () async {
                                      context.read<AudioProvider>().stopAll();
                                      final success = await currentProvider
                                          .deleteAccount();
                                      if (success && context.mounted) {
                                        AppRouter.navigateSequentially(
                                          context,
                                          AppRoutes.signUpPath,
                                        );
                                      } else if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                              child: currentProvider.isLoading
                                  ? SpinKitThreeBounce(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(
                                            alpha: ProfileConstants
                                                .disabledTextAlpha,
                                          ),
                                      size: ProfileConstants.loaderSize,
                                    )
                                  : const Text(
                                      ProfileConstants.deleteText,
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
      ),
    );
  }
}
