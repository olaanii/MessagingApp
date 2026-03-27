import 'package:flutter/material.dart';

import '../theme/app_design_tokens.dart';

/// Centers primary content and caps width on large screens (web / tablet).
class ResponsiveBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = AppDesignTokens.contentMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppDesignTokens.breakpointCompact;
        if (!wide) return child;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}

class AppLoadingState extends StatelessWidget {
  final String? message;

  const AppLoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: message ?? 'Loading',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: AppDesignTokens.paddingMedium),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.paddingLarge),
        child: Semantics(
          container: true,
          label: subtitle != null ? '$title. $subtitle' : title,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 56,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppDesignTokens.paddingMedium),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppDesignTokens.paddingSmall),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.paddingLarge),
        child: Semantics(
          container: true,
          label: message,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppDesignTokens.paddingMedium),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppDesignTokens.paddingLarge),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
