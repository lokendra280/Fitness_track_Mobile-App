import 'package:flutter/material.dart';
import 'package:habitflow/ads/config/rewarded_ad_service.dart';

Future<bool> showReportUnlockSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    builder: (_) => const _RewardGateSheet(),
  );
  return result ?? false;
}

class _RewardGateSheet extends StatefulWidget {
  const _RewardGateSheet();

  @override
  State<_RewardGateSheet> createState() => _RewardGateSheetState();
}

class _RewardGateSheetState extends State<_RewardGateSheet> {
  bool _loadingAd = false;
  String? _error;

  Future<void> _watchAd() async {
    setState(() {
      _loadingAd = true;
      _error = null;
    });

    final result = await RewardedAdService.instance.show();

    if (!mounted) return;

    switch (result) {
      case RewardedAdResult.earned:
        Navigator.of(context).pop(true);
      case RewardedAdResult.dismissedWithoutReward:
        setState(() {
          _loadingAd = false;
          _error = 'Watch the full ad to unlock your report.';
        });
      case RewardedAdResult.failedToLoad:
        setState(() {
          _loadingAd = false;
          _error = "Couldn't load an ad right now. Try again in a moment.";
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_circle_outline_rounded,
                size: 32,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text('Unlock your report', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Watch a short ad to view your daily, weekly, and monthly progress reports.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loadingAd ? null : _watchAd,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loadingAd
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Watch ad to unlock'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed:
                  _loadingAd ? null : () => Navigator.of(context).pop(false),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }
}
