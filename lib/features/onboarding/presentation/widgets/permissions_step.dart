import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../widgets/minimalist_card.dart';
import '../../../../widgets/minimalist_button.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class PermissionsStep extends StatefulWidget {
  const PermissionsStep({super.key});

  @override
  State<PermissionsStep> createState() => _PermissionsStepState();
}

class _PermissionsStepState extends State<PermissionsStep> {
  @override
  void initState() {
    super.initState();
    // Check permissions when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingBloc>().add(CheckPermissions());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      buildWhen: (previous, current) =>
          previous.permissionStatuses != current.permissionStatuses,
      builder: (context, state) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.spaceLG),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Grant Permissions',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignTokens.spaceSM),

                // Description
                Text(
                  'AutoQuill AI needs these permissions to provide the best experience',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignTokens.spaceLG),

                // Permission cards
                _buildPermissionCard(
                  context,
                  permissionType: PermissionType.microphone,
                  icon: Icons.mic,
                  title: PermissionService.getPermissionTitle(
                      PermissionType.microphone),
                  description: PermissionService.getPermissionDescription(
                      PermissionType.microphone),
                  status: state.permissionStatuses[PermissionType.microphone] ??
                      PermissionStatus.notDetermined,
                ),
                const SizedBox(height: DesignTokens.spaceMD),

                _buildPermissionCard(
                  context,
                  permissionType: PermissionType.screenRecording,
                  icon: Icons.screen_share,
                  title: PermissionService.getPermissionTitle(
                      PermissionType.screenRecording),
                  description: PermissionService.getPermissionDescription(
                      PermissionType.screenRecording),
                  status: state
                          .permissionStatuses[PermissionType.screenRecording] ??
                      PermissionStatus.notDetermined,
                ),
                const SizedBox(height: DesignTokens.spaceMD),

                _buildPermissionCard(
                  context,
                  permissionType: PermissionType.accessibility,
                  icon: Icons.accessibility,
                  title: PermissionService.getPermissionTitle(
                      PermissionType.accessibility),
                  description: PermissionService.getPermissionDescription(
                      PermissionType.accessibility),
                  status:
                      state.permissionStatuses[PermissionType.accessibility] ??
                          PermissionStatus.notDetermined,
                ),
                const SizedBox(height: DesignTokens.spaceLG),

                // All permissions granted message
                if (state.canProceedFromPermissions) ...[
                  MinimalistCard(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.1),
                    borderColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: DesignTokens.spaceSM),
                        Expanded(
                          child: Text(
                            'All permissions granted! You can now continue.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceSM),
                ],

                // Refresh permissions button
                Center(
                  child: MinimalistButton(
                    label: 'Check Permissions Again',
                    variant: MinimalistButtonVariant.secondary,
                    onPressed: () {
                      context.read<OnboardingBloc>().add(CheckPermissions());
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionCard(
    BuildContext context, {
    required PermissionType permissionType,
    required IconData icon,
    required String title,
    required String description,
    required PermissionStatus status,
  }) {
    final Color statusColor;
    final IconData statusIcon;
    final String statusText;
    final String buttonText;
    final VoidCallback? onPressed;

    switch (status) {
      case PermissionStatus.authorized:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Granted';
        buttonText = 'Granted';
        onPressed = null;
        break;
      case PermissionStatus.denied:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Denied';
        buttonText = 'Open Settings';
        onPressed = () {
          context.read<OnboardingBloc>().add(
                OpenSystemPreferences(permissionType: permissionType),
              );
        };
        break;
      case PermissionStatus.restricted:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        statusText = 'Restricted';
        buttonText = 'Open Settings';
        onPressed = () {
          context.read<OnboardingBloc>().add(
                OpenSystemPreferences(permissionType: permissionType),
              );
        };
        break;
      case PermissionStatus.notDetermined:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        statusText = 'Not Granted';
        buttonText = 'Grant Permission';
        onPressed = () {
          context.read<OnboardingBloc>().add(
                RequestPermission(permissionType: permissionType),
              );
        };
        break;
    }

    return MinimalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceSM),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: DesignTokens.spaceSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXS),
                    Row(
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 16,
                        ),
                        const SizedBox(width: DesignTokens.spaceXS),
                        Text(
                          statusText,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceMD),

          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: DesignTokens.spaceMD),

          // Action button
          SizedBox(
            width: double.infinity,
            child: MinimalistButton(
              label: buttonText,
              variant: status == PermissionStatus.authorized
                  ? MinimalistButtonVariant.secondary
                  : MinimalistButtonVariant.primary,
              isDisabled: status == PermissionStatus.authorized,
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
