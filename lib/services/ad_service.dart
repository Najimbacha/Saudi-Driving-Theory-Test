import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._();
  AdService._();

  static const Duration _rewardedMaxAge = Duration(minutes: 50);
  // Retry in the background indefinitely (capped backoff) so an ad is always
  // being prepared. Max delay between attempts.
  static const Duration _rewardedMaxRetryDelay = Duration(seconds: 60);
  // How long before expiry to preload a replacement in the background.
  static const Duration _rewardedRefreshLead = Duration(minutes: 2);

  // Production AdMob ad unit IDs (Android).
  static const String bannerId = 'ca-app-pub-9095390056353710/7128481632';
  static const String rewardedId =
      'ca-app-pub-9095390056353710/1917367616';
  bool _initialized = false;
  Timer? _expiryRefreshTimer;
  bool _lifecycleListening = false;

  /// Reactive notifier — UI can listen for rewarded ad readiness changes.
  final ValueNotifier<bool> rewardedReadyNotifier = ValueNotifier(false);

  /// Logs only in debug builds (keeps release output clean).
  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[AdService] $message');
    }
  }

  /// Starts background lifecycle watching + a continuous "keep ready" loop.
  void startBackgroundPrefetch() {
    if (!_lifecycleListening) {
      _lifecycleListening = true;
      WidgetsBinding.instance.addObserver(_AppLifecycleObserver());
    }
    // Kick off / keep alive the preload chain.
    loadRewarded();
  }

  Future<void> init() async {
    if (_initialized) return;
    _log('initialize');
    await MobileAds.instance.initialize();
    _initialized = true;
    _maybeScheduleExpiryRefresh();
  }

  BannerAd? createBanner({
    VoidCallback? onLoaded,
    VoidCallback? onFailed,
  }) {
    if (!_initialized) return null;
    if (bannerId.isEmpty) return null;
    return BannerAd(
      size: AdSize.banner,
      adUnitId: bannerId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _log('banner loaded');
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          _log('banner failed: ${error.message}');
          ad.dispose();
          onFailed?.call();
        },
      ),
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
    _expiryRefreshTimer?.cancel();
    _expiryRefreshTimer = null;
    rewardedReadyNotifier.value = false;
  }

  /// Schedules a background reload shortly before the loaded ad expires, so a
  /// fresh ad is ready whenever the user wants to watch.
  void _maybeScheduleExpiryRefresh() {
    _expiryRefreshTimer?.cancel();
    _expiryRefreshTimer = null;
    if (_rewarded == null || _rewardedLoadedAt == null) return;
    final elapsed = DateTime.now().difference(_rewardedLoadedAt!);
    final remaining = _rewardedMaxAge - elapsed;
    if (remaining <= Duration.zero) {
      _disposeRewarded();
      loadRewarded();
      return;
    }
    final delay = remaining - _rewardedRefreshLead;
    final safeDelay = delay > Duration.zero ? delay : _rewardedRefreshLead;
    _expiryRefreshTimer = Timer(safeDelay, () {
      _expiryRefreshTimer = null;
      _log('rewarded nearing expiry, reloading in background');
      _disposeRewarded();
      loadRewarded();
    });
  }

  void _scheduleRewardedRetry() {
    if (_rewardedRetryTimer != null) return;
    // Keep retrying in the background with capped exponential backoff so an ad
    // is always being prepared (e.g. after a transient failure).
    final delaySeconds = 2 * (1 << _rewardedRetryAttempt);
    final cappedDelay = delaySeconds > _rewardedMaxRetryDelay.inSeconds
        ? _rewardedMaxRetryDelay.inSeconds
        : delaySeconds;
    _rewardedRetryAttempt += 1;
    _rewardedRetryTimer = Timer(Duration(seconds: cappedDelay), () {
      _rewardedRetryTimer = null;
      loadRewarded();
    });
    _log('rewarded retry scheduled in ${cappedDelay}s');
  }

  /// Preload a rewarded ad in the background. Returns true when ready.
  Future<bool> loadRewarded() async {
    if (!_initialized) return false;
    if (_rewarded != null && _isRewardedExpired) {
      _log('rewarded expired, reloading');
      _disposeRewarded();
    }
    if (_rewarded != null) return true;
    final inFlight = _rewardedLoadCompleter;
    if (inFlight != null) return inFlight.future;
    if (rewardedId.isEmpty) {
      _log('rewarded id missing');
      return false;
    }
    _loadingRewarded = true;
    final completer = Completer<bool>();
    _rewardedLoadCompleter = completer;
    _rewardedRetryTimer?.cancel();
    _rewardedRetryTimer = null;
    _log('rewarded load start');
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
          rewardedReadyNotifier.value = true;
          _log('rewarded load success');
          _maybeScheduleExpiryRefresh();
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onAdFailedToLoad: (error) {
          _disposeRewarded();
          _loadingRewarded = false;
          _rewardedLoadCompleter = null;
          _log('rewarded load failed: ${error.message}');
          _scheduleRewardedRetry();
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      ),
    );
    return completer.future;
  }

  /// Ensures a rewarded ad is ready. Waits up to [timeout] for it to load.
  /// Unlike [loadRewarded], this will wait for any in-progress load AND
  /// start a new load if needed, with a deadline so the user doesn't wait forever.
  Future<bool> ensureRewardedReady({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    if (isRewardedReady) return true;
    // Kick off a load (no-op if already in-flight).
    final loadFuture = loadRewarded();
    // Race the load against a timeout.
    final result = await loadFuture.timeout(
      timeout,
      onTimeout: () => false,
    );
    return result;
  }

  Future<bool> showRewarded({required VoidCallback onReward}) async {
    if (!_initialized) return false;
    if (_rewarded != null && _isRewardedExpired) {
      _log('rewarded expired before show, reloading');
      _disposeRewarded();
    }
    if (_rewarded == null) {
      final loaded = await loadRewarded();
      if (!loaded) {
        _log('rewarded show aborted (load failed)');
        return false;
      }
    }
    final ad = _rewarded;
    if (ad == null) {
      _log('rewarded show skipped (no ad loaded)');
      return false;
    }
    final completer = Completer<bool>();
    var rewardEarned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _log('rewarded shown');
      },
      onAdDismissedFullScreenContent: (_) {
        _log('rewarded dismissed');
        _disposeRewarded();
        // Immediately preload next rewarded ad in background.
        loadRewarded();
        if (!completer.isCompleted) {
          completer.complete(rewardEarned);
        }
      },
      onAdFailedToShowFullScreenContent: (_, __) {
        _log('rewarded failed to show');
        _disposeRewarded();
        loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    ad.show(onUserEarnedReward: (_, __) {
      _log('rewarded earned');
      if (!rewardEarned) {
        rewardEarned = true;
        onReward();
      }
    });
    return completer.future;
  }
}

/// Reloads the rewarded ad when the app returns to the foreground, so a ready
/// ad is always available after coming back from background.
class _AppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final service = AdService.instance;
      // Refresh if the current ad is stale or missing.
      if (!service.isRewardedReady) {
        service.loadRewarded();
      }
    }
  }
}
