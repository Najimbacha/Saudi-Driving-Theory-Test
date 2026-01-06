import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._();
  AdService._();

  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testRewardedIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String testRewardedIdIos =
      'ca-app-pub-3940256099942544/1712485313';
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    debugPrint('[AdService] initialize');
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

  bool get isRewardedReady => _rewarded != null;
  bool get isLoadingRewarded => _loadingRewarded;

  Future<bool> loadRewarded() async {
    if (!_initialized) return false;
    if (_rewarded != null) return true;
    if (_loadingRewarded) return false;
    final rewardedId = kReleaseMode
        ? ''
        : (Platform.isIOS ? testRewardedIdIos : testRewardedIdAndroid);
    if (rewardedId.isEmpty) return false;
    _loadingRewarded = true;
    debugPrint('[AdService] rewarded load start');
    await RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _loadingRewarded = false;
          debugPrint('[AdService] rewarded load success');
        },
        onAdFailedToLoad: (error) {
          _rewarded = null;
          _loadingRewarded = false;
          debugPrint('[AdService] rewarded load failed: ${error.message}');
        },
      ),
    );
    return _rewarded != null;
  }

  Future<bool> showRewarded({required VoidCallback onReward}) async {
    if (!_initialized) return false;
    final ad = _rewarded;
    if (ad == null) {
      debugPrint('[AdService] rewarded show skipped (no ad loaded)');
      return false;
    }
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        debugPrint('[AdService] rewarded shown');
      },
      onAdDismissedFullScreenContent: (_) {
        debugPrint('[AdService] rewarded dismissed');
        ad.dispose();
        _rewarded = null;
        loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (_, __) {
        debugPrint('[AdService] rewarded failed to show');
        ad.dispose();
        _rewarded = null;
        loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    ad.show(onUserEarnedReward: (_, __) {
      debugPrint('[AdService] rewarded earned');
      onReward();
      if (!completer.isCompleted) completer.complete(true);
    });
    return completer.future;
  }
}
