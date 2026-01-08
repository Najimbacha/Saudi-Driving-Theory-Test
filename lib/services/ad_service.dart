import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._();
  AdService._();

  static const Duration _rewardedMaxAge = Duration(minutes: 50);
  // Toggle to force test ads during development.
  static const bool useTestAds = true;
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testRewardedIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String testRewardedIdIos =
      'ca-app-pub-3940256099942544/1712485313';
  static const String productionBannerId = '';
  static const String productionRewardedIdAndroid = '';
  static const String productionRewardedIdIos = '';
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    debugPrint('[AdService] initialize');
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  BannerAd? createBanner() {
    if (!_initialized) return null;
    const bannerId = useTestAds ? testBannerId : productionBannerId;
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
  Completer<bool>? _rewardedLoadCompleter;
  DateTime? _rewardedLoadedAt;
  Timer? _rewardedRetryTimer;
  int _rewardedRetryAttempt = 0;

  bool get isRewardedReady => _rewarded != null && !_isRewardedExpired;
  bool get isLoadingRewarded => _loadingRewarded;

  bool get _isRewardedExpired {
    if (_rewarded == null) return false;
    final loadedAt = _rewardedLoadedAt;
    if (loadedAt == null) return true;
    return DateTime.now().difference(loadedAt) > _rewardedMaxAge;
  }

  void _disposeRewarded() {
    _rewarded?.dispose();
    _rewarded = null;
    _rewardedLoadedAt = null;
  }

  void _scheduleRewardedRetry() {
    if (_rewardedRetryTimer != null) return;
    final delaySeconds = 4 * (1 << _rewardedRetryAttempt);
    final cappedDelay = delaySeconds > 60 ? 60 : delaySeconds;
    if (_rewardedRetryAttempt < 5) {
      _rewardedRetryAttempt += 1;
    }
    _rewardedRetryTimer = Timer(Duration(seconds: cappedDelay), () {
      _rewardedRetryTimer = null;
      loadRewarded();
    });
    debugPrint('[AdService] rewarded retry scheduled in ${cappedDelay}s');
  }

  Future<bool> loadRewarded() async {
    if (!_initialized) return false;
    if (_rewarded != null && _isRewardedExpired) {
      debugPrint('[AdService] rewarded expired, reloading');
      _disposeRewarded();
    }
    if (_rewarded != null) return true;
    final inFlight = _rewardedLoadCompleter;
    if (inFlight != null) return inFlight.future;
    final rewardedId = useTestAds
        ? (Platform.isIOS ? testRewardedIdIos : testRewardedIdAndroid)
        : (Platform.isIOS
            ? productionRewardedIdIos
            : productionRewardedIdAndroid);
    if (rewardedId.isEmpty) {
      debugPrint('[AdService] rewarded id missing');
      return false;
    }
    _loadingRewarded = true;
    final completer = Completer<bool>();
    _rewardedLoadCompleter = completer;
    _rewardedRetryTimer?.cancel();
    _rewardedRetryTimer = null;
    debugPrint('[AdService] rewarded load start');
    RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _rewardedLoadedAt = DateTime.now();
          _loadingRewarded = false;
          _rewardedLoadCompleter = null;
          _rewardedRetryAttempt = 0;
          debugPrint('[AdService] rewarded load success');
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onAdFailedToLoad: (error) {
          _disposeRewarded();
          _loadingRewarded = false;
          _rewardedLoadCompleter = null;
          debugPrint('[AdService] rewarded load failed: ${error.message}');
          _scheduleRewardedRetry();
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      ),
    );
    return completer.future;
  }

  Future<bool> showRewarded({required VoidCallback onReward}) async {
    if (!_initialized) return false;
    if (_rewarded != null && _isRewardedExpired) {
      debugPrint('[AdService] rewarded expired before show, reloading');
      _disposeRewarded();
    }
    if (_rewarded == null) {
      final loaded = await loadRewarded();
      if (!loaded) {
        debugPrint('[AdService] rewarded show aborted (load failed)');
        return false;
      }
    }
    final ad = _rewarded;
    if (ad == null) {
      debugPrint('[AdService] rewarded show skipped (no ad loaded)');
      return false;
    }
    final completer = Completer<bool>();
    var rewardEarned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        debugPrint('[AdService] rewarded shown');
      },
      onAdDismissedFullScreenContent: (_) {
        debugPrint('[AdService] rewarded dismissed');
        _disposeRewarded();
        loadRewarded();
        if (!completer.isCompleted) {
          completer.complete(rewardEarned);
        }
      },
      onAdFailedToShowFullScreenContent: (_, __) {
        debugPrint('[AdService] rewarded failed to show');
        _disposeRewarded();
        loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    ad.show(onUserEarnedReward: (_, __) {
      debugPrint('[AdService] rewarded earned');
      if (!rewardEarned) {
        rewardEarned = true;
        onReward();
      }
    });
    return completer.future;
  }
}
