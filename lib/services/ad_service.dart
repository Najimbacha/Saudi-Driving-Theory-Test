import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._();
  AdService._();

  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  BannerAd? createBanner() {
    if (!_initialized) return null;
    const bannerId = kReleaseMode ? '' : testBannerId;
    if (bannerId.isEmpty) return null;
    return BannerAd(
      size: AdSize.banner,
      adUnitId: bannerId,
      listener: const BannerAdListener(),
      request: const AdRequest(),
    );
  }

  RewardedAd? _rewarded;
  bool _loadingRewarded = false;

  Future<void> loadRewarded() async {
    if (!_initialized) return;
    if (_loadingRewarded) return;
    const rewardedId = kReleaseMode ? '' : testRewardedId;
    if (rewardedId.isEmpty) return;
    _loadingRewarded = true;
    await RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _loadingRewarded = false;
        },
        onAdFailedToLoad: (_) {
          _rewarded = null;
          _loadingRewarded = false;
        },
      ),
    );
  }

  Future<bool> showRewarded({required VoidCallback onReward}) async {
    if (!_initialized) return false;
    final ad = _rewarded;
    if (ad == null) return false;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) {
        _rewarded = null;
        loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (_, __) {
        _rewarded = null;
        loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    ad.show(onUserEarnedReward: (_, __) {
      onReward();
      if (!completer.isCompleted) completer.complete(true);
    });
    return completer.future;
  }
}
