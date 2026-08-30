import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:habitflow/ads/config/ads_config.dart';

enum RewardedAdResult { earned, dismissedWithoutReward, failedToLoad }

class RewardedAdService {
  RewardedAdService._();
  static final instance = RewardedAdService._();

  Future<RewardedAdResult> show() async {
    final completer = <RewardedAdResult>[];

    await RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          bool earnedReward = false;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              completer.add(
                earnedReward
                    ? RewardedAdResult.earned
                    : RewardedAdResult.dismissedWithoutReward,
              );
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              completer.add(RewardedAdResult.failedToLoad);
            },
          );

          ad.show(
            onUserEarnedReward: (ad, reward) {
              earnedReward = true;
            },
          );
        },
        onAdFailedToLoad: (error) {
          completer.add(RewardedAdResult.failedToLoad);
        },
      ),
    );

    // RewardedAd.load's callbacks fire asynchronously outside the
    // Future it returns, so poll until one of them appends a result.
    // Simpler alternative to a raw Completer given the two independent
    // callback paths (load failure vs. show dismissal) that both need
    // to resolve the same outcome.
    while (completer.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    return completer.first;
  }
}
